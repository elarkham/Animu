defmodule Golem do
  @moduledoc """
  Manages async tasks
  """
  use GenServer

  alias __MODULE__

  defstruct [
    :id,
    :created_at,
    :updated_at,

    :worker,
    :arguments,

    :status,
    :progress,
  ]

  @custom [:progress]

  ### Delegates

  defdelegate setup!, to: Golem.Que
  defdelegate initialize, to: Golem.Que

  ### Helpers

  def job_to_golem(job) do
    progress =
      case job.status do
        :completed -> 100.0
        _ -> 0.0
      end

    %Golem{
      id: job.id,
      created_at: job.created_at,
      updated_at: job.updated_at,

      worker: job.worker,
      arguments: job.arguments,

      status: job.status,
      progress: progress,
    }
  end

  def job_cache_merge(jobs, cache) do
    cache = Map.values(cache)
    jobs
    |> Enum.map(&job_to_golem/1)
    |> Map.new(fn g -> {g.id, g} end)
    |> Map.merge(cache, fn k, v1, v2 ->
      cond do
        custom_field?(k) -> v2
        true -> v1
      end
    end)
    |> Map.values
    |> Enum.sort(fn g1, g2 -> g1.id <= g2.id end)
  end

  def custom_field?(field) do
    Enum.member?(@custom, field)
  end

  ### Client

  @doc """
  Start Link
  """
  def start_link(name \\ nil) do
    GenServer.start_link(__MODULE__, :ok, [name: name])
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def add(module, params) do
    {:ok, job} = Que.add(module, params)
    golem = job_to_golem(job)
    {:ok, golem}
  end

  def cache do
    GenServer.call(Golem, :cache)
  end

  def all do
    GenServer.call(Golem, :all)
  end

  def completed do
    GenServer.call(Golem, :completed)
  end

  def incomplete do
    GenServer.call(Golem, :incomplete)
  end

  def failed do
    GenServer.call(Golem, :failed)
  end

  def assign_pid(pid, %Golem{} = golem) do
    GenServer.cast(Golem, {:assign_pid, pid, golem})
  end

  def update(pid, %Golem{} = golem) do
    GenServer.cast(Golem, {:update, pid, golem})
  end

  ### Server

  def handle_call(:cache, _from, cache) do
    {:reply, cache, cache}
  end

  def handle_call(:all, _from, cache) do
    golems = job_cache_merge(Golem.Que.all, cache)
    {:reply, golems, cache}
  end

  def handle_call(:completed, _from, cache) do
    golems = job_cache_merge(Golem.Que.completed, cache)
    {:reply, golems, cache}
  end

  def handle_call(:incomplete, _from, cache) do
    golems = job_cache_merge(Golem.Que.incomplete, cache)
    {:reply, golems, cache}
  end

  def handle_call(:failed, _from, cache) do
    golems = job_cache_merge(Golem.Que.failed, cache)
    {:reply, golems, cache}
  end

  def handle_cast({:assign_pid, pid, %Golem{} = golem}, _from, cache) do
    cache = Map.put_new(cache, pid, golem)
    {:noreply, cache}
  end

  def handle_cast({:update, pid, %Golem{} = golem}, _from, cache) do
    golem =
      cache[pid]
      |> Map.merge(golem, fn k, v1, v2 ->
        cond do
          custom_field?(k) -> v2
          true -> v1
        end
      end)

    cache = Map.put(cache, pid, golem)
    {:noreply, cache}
  end

end

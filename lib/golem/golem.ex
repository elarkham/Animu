defmodule Golem do
  @moduledoc """
  Manages async tasks
  """
  alias Que.Persistence, as: QueDB

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
    Que.add(module, params)
  end

  def setup!, do: QueDB.Mnesia.setup!
  def setup!(nodes) do
    QueDB.Mnesia.setup!(nodes)
  end

  defdelegate initialize, to: QueDB

  defdelegate all, to: QueDB
  defdelegate all(worker), to: QueDB

  defdelegate completed, to: QueDB
  defdelegate completed(worker), to: QueDB

  defdelegate incomplete, to: QueDB
  defdelegate incomplete(worker), to: QueDB

  defdelegate failed, to: QueDB
  defdelegate failed(worker), to: QueDB

  defdelegate find(job_id), to: QueDB

  defdelegate destroy(job_id), to: QueDB

  defdelegate insert(job), to: QueDB

  defdelegate update(job), to: QueDB

end

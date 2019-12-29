defmodule Golem.Supervisor do
  @moduledoc """
  Golem Supervisor
  """
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Golem, [Golem])
    ]

    opts = [strategy: :one_for_all, name: Golem.Supervisor]
    supervise(children, opts)
  end

end

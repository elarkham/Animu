defmodule Animu.Application do
  @moduledoc """
  Starts and supervises Animu processes
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      # Start the Ecto repository
      supervisor(Animu.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Animu.Web.Endpoint, []),
      # Start Golem
      supervisor(Golem.Supervisor, [])
    ]

    augur = [
      # Auto downlaod new episodes by scanning RSS Feeds
      supervisor(Augur.Supervisor, [])
    ]

    children =
      case System.get_env("AUGUR") do
        "false" -> children
        _       -> children ++ augur
      end

    opts = [strategy: :one_for_one, name: Animu.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

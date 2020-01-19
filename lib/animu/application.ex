defmodule Animu.Application do
  @moduledoc """
  Starts and supervises Animu processes
  """
  use Application

  def start(_type, _args) do

    children = [
      # Start the Ecto repository
      {Animu.Repo, []},

      # Start the endpoint when the application starts
      {Animu.Web.Endpoint, []},

      # Start Golem
      {Kiln.Supervisor, []},
    ]

    augur = [
      # Auto downlaod new episodes by scanning RSS Feeds
      {Augur.Supervisor, []}
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

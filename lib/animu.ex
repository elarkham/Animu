defmodule Animu do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Animu.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Animu.Web.Endpoint, []),

      # RSS feed reader
      worker(Animu.Reader, [Animu.Reader]),
      # Torrent Registry that tracks transmission downloads
      worker(Animu.TransmissionClient, [Animu.TransmissionClient]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Animu.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

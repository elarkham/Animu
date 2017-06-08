defmodule Augur.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do

    children = [
      # Primary command interface
      worker(Augur, [Augur]),
      # Handles RSS feed Scanning
      worker(Augur.Scanner, [Augur.Scanner]),
      # Interface that facilitates interactions with transmission
      worker(Augur.Transmission, [Augur.Transmission])
    ]

    opts = [strategy: :one_for_all, name: Augur.Supervisor]
    supervise(children, opts)
  end

end

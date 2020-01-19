defmodule Augur.Transmission.Supervisor do
  @moduledoc """
  Transmission Supervisor
  """
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do

    children = [
      # Interface that facilitates interactions with transmission
      {Augur.Transmission, []},

      # Cache that stores transmission torrent status
      {Augur.Transmission.Cache, []},
    ]

    opts = [strategy: :one_for_all, name: __MODULE__]
    Supervisor.init(children, opts)
  end

end

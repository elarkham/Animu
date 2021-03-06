defmodule Augur.Supervisor do
  @moduledoc """
  Augur Supervisor
  """
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do

    children = [

      # Shared PubSub
      {Phoenix.PubSub.PG2, name: Augur.PubSub},

      # Primary command interface
      {Augur, []},

      # Handles RSS feed Scanning
      {Augur.Scanner, []},

      # Interface that facilitates interactions with transmission
      {Augur.Transmission, []},

    ]

    opts = [strategy: :one_for_all, name: __MODULE__]
    Supervisor.init(children, opts)
  end

end

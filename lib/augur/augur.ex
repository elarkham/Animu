defmodule Augur do
  @moduledoc """
  Scans RSS feeds and auto-downloads anime episodes at fixed interval
  """
  use GenServer

  alias Augur.Transmission
  alias Augur.Transmission.Torrent

  alias Phoenix.PubSub

  require Logger

  ##############
  #   Client   #
  ##############

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  ##############
  #   Server   #
  ##############

  def init(_) do
    # Handle Transmission Events
    PubSub.subscribe(Augur.PubSub, "transmission")
    {:ok, %{}}
  end

  @doc """
  Cached torrent states from transmission
  """
  def handle_info({Transmission, {:complete, torrent}}, state) do
    case duplicate_torrent?(torrent) do
      true  -> :skip
      false -> handle_completed_torrent(torrent)
    end
    {:noreply, state}
  end

  ###############
  #   Helpers   #
  ###############

  defp duplicate_torrent?(torrent = %Torrent{}) do
    Kiln.Cache.all(:active)
    |> Enum.any?(fn %{label: label} ->
      match?(^label, {Augur, %{ep_id: torrent.label.ep_id}})
    end)
  end

  defp handle_completed_torrent(torrent = %Torrent{}) do
    Kiln.bake(Animu.Kiln.Video, [
      path: {torrent.download_dir, torrent.name},
      ep_id: torrent.label.ep_id,
      augured_at: torrent.augured_at,
    ],
      label: {Augur, %{ep_id: torrent.label.ep_id}}
    )
  end

end

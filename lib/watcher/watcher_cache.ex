defmodule Animu.WatcherCache do
  use GenServer

  alias HTTPoison.Response
  alias Animu.{TransmissionClient, Reader, Torrent, Repo}

  def start_link(_,_) do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(cache) do
    cache = update(cache)
    {:ok, cache}
  end

  defp update(cache) do

  end

  def handle_cast(:process, state) do

    {:noreply, state}
  end



end

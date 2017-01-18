defmodule Owl.TorrentRegistry do
  use GenServer
  alias Owl.{Reader, Transmission}

  def start_link(_,_) do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(state) do
    %HTTPoison.Response{body: body} =
    {:ok, state}
  end

  def handle_call(:pop, _from, state) do

  end

end

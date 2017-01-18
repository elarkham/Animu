defmodule Animu.TorrentRegistry do
  use GenServer

  alias Animu.Reader
  alias HTTPoison.Response

  def start_link(_,_) do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(state) do
  #    Response{body: body} =
    {:ok, state}
  end

  def handle_call(:pop, _from, state) do

  end

end

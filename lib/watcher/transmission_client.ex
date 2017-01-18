defmodule Animu.TransmissionClient do
  use GenServer

  alias HTTPoison.Response
  alias Animu.{WatcherCache, Reader}

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

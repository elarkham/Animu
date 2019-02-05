defmodule Animu.Web.TestChannel do
  use Phoenix.Channel

  def join("test:test", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("ping", _, socket) do
    broadcast(socket, "msg", %{body: "pong"})
    {:noreply, socket}
  end

end

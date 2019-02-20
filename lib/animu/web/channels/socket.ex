defmodule Animu.Web.Socket do
  use Phoenix.Socket

  alias Guardian.Phoenix.Socket, as: SocketAuth

  ## Channels
  channel "test:*", Animu.Web.TestChannel

  channel "golem:*", Animu.Web.GolemChannel

  channel "anime:*",    Animu.Web.AnimeChannel
  channel "episode:*",   Animu.Web.EpisodeChannel
  channel "franchise:*", Animu.Web.FranchiseChannel

  def connect(%{"token" => token}, socket) do
    case SocketAuth.authenticate(socket, Animu.Auth.Guardian, token) do
      {:ok, socket} ->
        {:ok, socket}
      {:error,_ } ->
        :error
    end
  end
  def connect(_params, _socket) do
    :error
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     PhoenixTest.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end

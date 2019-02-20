defmodule Animu.Web.AnimeChannel do
  use Phoenix.Channel

  alias Animu.Web
  alias Animu.Media
  alias Animu.Media.Anime

  def join("anime:", _payload, socket) do
    {:ok, socket}
  end

  def join("anime:" <> id, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("index", _params, socket) do
    anime = Media.list_anime(%{})
    view = Web.AnimeView.render("index.json", anime: anime)
    {:reply, {:ok, view}, socket}
  end

  def handle_in("get", %{"id" => id}, socket) do
    anime = Media.get_anime!(id)
    view = Web.AnimeView.render("show.json", anime: anime)
    {:reply, {:ok, view}, socket}
  end

  def handle_in("new", _, socket) do
    broadcast(socket, "msg", %{body: "pong"})
    {:noreply, socket}
  end

  def handle_in("update", _, socket) do
    broadcast(socket, "msg", %{body: "pong"})
    {:noreply, socket}
  end

  def handle_in("delete", _, socket) do
    broadcast(socket, "msg", %{body: "pong"})
    {:noreply, socket}
  end

  defp parse(slug) do
    case Integer.parse(slug) do
      {id, _} -> id
      :error -> slug
    end
  end
end

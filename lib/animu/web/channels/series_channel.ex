defmodule Animu.Web.SeriesChannel do
  use Phoenix.Channel

  alias Animu.Web
  alias Animu.Media
  alias Animu.Media.Series

  def join("series:", _payload, socket) do
    {:ok, socket}
  end

  def join("series:" <> id, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("index", _params, socket) do
    series = Media.list_series(%{})
    view = Web.SeriesView.render("index.json", series: series)
    {:reply, {:ok, view}, socket}
  end

  def handle_in("get", %{"id" => id}, socket) do
    series = Media.get_series!(id)
    view = Web.SeriesView.render("show.json", series: series)
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

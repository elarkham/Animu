defmodule Animu.Web.AnimeController do
  use Animu.Web, :controller

  alias Animu.Media
  alias Animu.Media.Anime

  plug :put_view, Animu.Web.AnimeView
  action_fallback Animu.Web.FallbackController

  def index(conn, params) do
    anime = Media.list_anime(params)
    render(conn, "index.json", anime: anime)
  end

  def create(conn, %{"anime" => anime_params}) do
    with {:ok, %Anime{} = anime} <- Media.create_anime(anime_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", anime_path(conn, :show, anime))
      |> render("show.json", anime: anime)
    end
  end

  def show(conn, %{"id" => id}) do
    anime = parse(id) |> Media.get_anime!()
    render(conn, "show.json", anime: anime)
  end

  def update(conn, %{"id" => id, "anime" => anime_params}) do
    anime = parse(id) |> Media.get_anime!()
    with {:ok, %Anime{} = anime} <- Media.update_anime(anime, anime_params) do
      render(conn, "show.json", anime: anime)
    end
  end

  def delete(conn, %{"id" => id}) do
    anime = parse(id) |> Media.get_anime!()
    with {:ok, %Anime{}} <- Media.delete_anime(anime) do
      send_resp(conn, :no_content, "")
    end
  end

  defp parse(slug) do
    case Integer.parse(slug) do
      {id, _} -> id
      :error -> slug
    end
  end
end

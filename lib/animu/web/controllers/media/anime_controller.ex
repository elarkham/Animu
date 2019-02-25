defmodule Animu.Web.AnimeController do
  use Animu.Web, :controller

  alias Animu.Media
  alias Animu.Media.Anime

  plug :put_view, Animu.Web.AnimeView
  action_fallback Animu.Web.FallbackController

  ## Helpers
  defp parse(slug) do
    case Integer.parse(slug) do
      {id, _} -> id
      :error -> slug
    end
  end

  #### GET

  ## Index
  def index(conn, params) do
    anime = Media.list_anime(params)
    render(conn, "index.json", anime: anime)
  end

  ## Show
  def show(conn, %Anime{} = anime) do
    render(conn, "show.json", anime: anime)
  end
  def show(conn, %{"franchise_id" => id, "num" => num}) do
    anime = Media.get_anime!(parse(id), num)
    show(conn, anime)
  end
  def show(conn, %{"id" => id}) do
    anime = Media.get_anime!(parse(id))
    show(conn, anime)
  end

  #### POST/PATCH

  ## Create
  def create(conn, params = %{"anime" => attrs}) do
    opt = params["options"] || %{}
    with {:ok, %Anime{} = anime} <- Media.create_anime(attrs, opt) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", anime_path(conn, :show, anime))
      |> render("show.json", anime: anime)
    end
  end

  ## Update
  def update(conn, %Anime{} = anime, %{"anime" => attrs} = params) do
    opt = params["options"] || %{}
    with {:ok, %Anime{} = anime} <- Media.update_anime(anime, attrs, opt) do
      render(conn, "show.json", anime: anime)
    end
  end
  def update(conn, params = %{"franchise_id" => id, "num" => num}) do
    anime = Media.get_anime!(parse(id), num)
    update(conn, anime, params)
  end
  def update(conn, params = %{"id" => id}) do
    anime = Media.get_anime!(parse(id))
    update(conn, anime, params)
  end

  #### DELETE

  ## Delete
  def delete(conn, %{"id" => id}) do
    anime = parse(id) |> Media.get_anime!()
    with {:ok, %Anime{}} <- Media.delete_anime(anime) do
      send_resp(conn, :no_content, "")
    end
  end

end

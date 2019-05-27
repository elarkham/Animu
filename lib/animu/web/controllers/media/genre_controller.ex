defmodule Animu.Web.GenreController do
  use Animu.Web, :controller

  alias Animu.Media
  alias Animu.Media.Anime.Genre

  plug :put_view, Animu.Web.GenreView
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
    genres = Media.list_genres(params)
    render(conn, "index.json", genres: genres)
  end

  ## Show
  def show(conn, %Genre{} = genre) do
    render(conn, "show.json", genre: genre)
  end
  def show(conn, %{"id" => id}) do
    genres = Media.get_genre!(parse(id))
    show(conn, genres)
  end

end

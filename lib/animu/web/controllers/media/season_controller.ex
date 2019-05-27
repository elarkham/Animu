defmodule Animu.Web.SeasonController do
  use Animu.Web, :controller

  alias Animu.Media
  alias Animu.Media.Anime.Season

  plug :put_view, Animu.Web.SeasonView
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
    seasons = Media.list_seasons(params)
    render(conn, "index.json", seasons: seasons)
  end

  ## Show
  def show(conn, %Season{} = season) do
    render(conn, "show.json", season: season)
  end
  def show(conn, %{"id" => id}) do
    season = Media.get_season!(parse(id))
    show(conn, season)
  end

end

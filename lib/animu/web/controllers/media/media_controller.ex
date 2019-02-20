defmodule Animu.Web.MediaController do
  use Animu.Web, :controller

  alias Animu.Media
  alias Animu.Media.{Anime, Franchise}

  action_fallback Animu.Web.FallbackController

  def index(conn, params) do
    anime = Media.list_anime(params)
    render(conn, "index.json", anime: anime)
  end

end

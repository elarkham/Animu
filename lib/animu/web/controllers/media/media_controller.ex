defmodule Animu.Web.MediaController do
  use Animu.Web, :controller

  alias Animu.Media
  alias Animu.Media.{Series, Franchise}

  action_fallback Animu.Web.FallbackController

  def index(conn, params) do
    series = Media.list_series(params)
    render(conn, "index.json", series: series)
  end

end

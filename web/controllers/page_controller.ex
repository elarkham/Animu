defmodule Animu.PageController do
  use Animu.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

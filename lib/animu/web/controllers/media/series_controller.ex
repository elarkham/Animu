defmodule Animu.Web.SeriesController do
  use Animu.Web, :controller

  alias Animu.Media
  alias Animu.Media.Series

  plug :put_view, Animu.Web.SeriesView
  action_fallback Animu.Web.FallbackController

  def index(conn, params) do
    series = Media.list_series(params)
    render(conn, "index.json", series: series)
  end

  def create(conn, %{"series" => series_params}) do
    with {:ok, %Series{} = series} <- Media.create_series(series_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", series_path(conn, :show, series))
      |> render("show.json", series: series)
    end
  end

  def show(conn, %{"id" => id}) do
    series = parse(id) |> Media.get_series!()
    render(conn, "show.json", series: series)
  end

  def update(conn, %{"id" => id, "series" => series_params}) do
    series = parse(id) |> Media.get_series!()
    with {:ok, %Series{} = series} <- Media.update_series(series, series_params) do
      render(conn, "show.json", series: series)
    end
  end

  def delete(conn, %{"id" => id}) do
    series = parse(id) |> Media.get_series!()
    with {:ok, %Series{}} <- Media.delete_series(series) do
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

defmodule Animu.SeriesController do
  use Animu.Web, :controller

  alias Animu.Series
  alias Animu.QueryBuilder

  plug Guardian.Plug.EnsureAuthenticated, handler: Animu.SessionController

  def index(conn, params) do
    query = QueryBuilder.build(Series, params)
    series =
      Repo.all(query)
      |> Repo.preload(:episodes)
    render(conn, "index.json", series: series)
  end

  def create(conn, %{"series" => series_params}) do
    changeset =
      %Series{}
      |> Series.changeset(series_params)
      |> Series.search_existing_ep
      |> Series.fill_with_new_ep

    IO.inspect changeset

    case Repo.insert(changeset) do
      {:ok, series} ->
        series =
          series
          |> Repo.preload(:episodes)
          |> Repo.preload(:franchise)

        conn
        |> put_status(:created)
        |> put_resp_header("location", series_path(conn, :show, series))
        |> render("show.json", series: series)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Animu.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    series =
      Series
      |> Repo.get!(id)
      |> Repo.preload(:episodes)
      |> Repo.preload(:franchise)
    render(conn, "show.json", series: series)
  end

  def update(conn, %{"id" => id, "series" => series_params}) do
    series = Series |> Repo.get!(id)
    changeset = Series.changeset(series, series_params)

    case Repo.update(changeset) do
      {:ok, series} ->
        series =
          series
          |> Repo.preload(:episodes)
          |> Repo.preload(:franchise)

        render(conn, "show.json", series: series)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Animu.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    series = Repo.get!(Series, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(series)

    send_resp(conn, :no_content, "")
  end
end

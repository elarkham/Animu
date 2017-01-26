defmodule Animu.SeriesController do
  use Animu.Web, :controller

  import Animu.ModelHelper
  import Animu.SeriesPopulator

  alias Animu.{Series, Episode}

  plug Guardian.Plug.EnsureAuthenticated, handler: Animu.SessionController

  def index(conn, _params) do
    series = Series |> Repo.all |> Repo.preload(:episodes)
    render(conn, "index.json", series: series)
  end

  def create(conn, %{"series" => series_params}) do
    params = populate(series_params)
    episodes = Episode.new(params.episode_count)
    changeset =
      %Series{}
      |> Series.changeset(to_map(params))
      |> Ecto.Changeset.put_assoc(:episodes, episodes)

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
    params =
      series_params
      |> populate
      |> to_map
      |> Enum.filter(fn {_k, v} -> v != nil end)
      |> Map.new

    changeset = Series.changeset(series, params)

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

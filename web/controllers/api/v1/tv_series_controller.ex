defmodule Animu.TVSeriesController do
  use Animu.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Animu.SessionController
  plug :scrub_params, "tv_series" when action in [:create, :update]

  alias Animu.{Repo, TVSeries}

  # List all TV Shows
  def index(conn, _params) do
    tv_series = Repo.all(TVSeries)
    render(conn, "index.json", tv_series: tv_series)
  end

  # Create new TV Show with given params
  def create(conn, %{"tv_series" => tv_series_params }) do
    changeset = TVSeries.changeset(tv_series_params)

    case Repo.insert(changeset) do
      {:ok, tv_series} ->
        conn
        |> put_status(:created)
        |> render("show.json", tv_series: tv_series )
      {:error, changeset } ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", changeset: changeset)
    end
  end

  # Show TV Show with given id
  def show(conn, %{"id" => id}) do
    tv_series = Repo.get(TVSeries, id)
    render( conn, "show.json", tv_series: tv_series )
  end

  # Update TV Show with given id with the given params
  def update(conn, %{"id" => id, "tv_series" => tv_series_params}) do
    tv_series = Repo.get(TVSeries, id)
    changeset = TVSeries.changeset(tv_series, tv_series_params)

    case Repo.update(changeset) do
      {:ok, tv_series} ->
        conn
        |> put_status(:created)
        |> render("show.json", tv_series: tv_series )
      {:error, changeset } ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", changeset: changeset)
    end
  end

  # Delete TV Show with given id
  def delete(conn, %{"id" => id}) do
    tv_series = Repo.get(TVSeries, id)

    case Repo.delete(tv_series) do
      {:ok, tv_series} ->
        conn
        |> put_status(:created)
        |> render("show.json", tv_series: tv_series)
      {:error, changeset } ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", changeset: changeset)
    end
  end

end

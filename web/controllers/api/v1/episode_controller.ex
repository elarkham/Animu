defmodule Animu.EpisodeController do
  use Animu.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Animu.SessionController
  plug :scrub_params, "episode" when action in [:create, :update]

  alias Animu.{Repo, Episode}

  # List all Episodes
  def index(conn, _params) do
    episode = Repo.all(Episode)
    render(conn, "index.json", episode: episode)
  end

  # Create new Episode with given params
  def create(conn, %{"episode" => episode_params }) do
    changeset = Episode.changeset(episode_params)

    case Repo.insert(changeset) do
      {:ok, episode} ->
        conn
        |> put_status(:created)
        |> render("show.json", episode: episode )
      {:error, changeset } ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", changeset: changeset)
    end
  end

  # Show Episode with given id
  def show(conn, %{"id" => id}) do
    episode = Repo.get(Episode, id)
    render( conn, "show.json", episode: episode )
  end

  # Update Episode with given id with the given params
  def update(conn, %{"id" => id, "episode" => episode_params}) do
    episode = Repo.get(Episode, id)
    changeset = Episode.changeset(episode, episode_params)

    case Repo.update(changeset) do
      {:ok, episode} ->
        conn
        |> put_status(:created)
        |> render("show.json", episode: episode )
      {:error, changeset } ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", changeset: changeset)
    end
  end

  # Delete Episode with given id
  def delete(conn, %{"id" => id}) do
    episode = Repo.get(Episode, id)

    case Repo.delete(episode) do
      {:ok, episode} ->
        conn
        |> put_status(:created)
        |> render("show.json", episode: episode)
      {:error, changeset } ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", changeset: episode)
    end
  end

end

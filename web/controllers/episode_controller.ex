defmodule Animu.EpisodeController do
  use Animu.Web, :controller

  alias Animu.{Episode, Repo}
  plug Guardian.Plug.EnsureAuthenticated, handler: Animu.SessionController

  def index(conn, _params) do
    episodes = Repo.all(Episode)
    render(conn, "index.json", episodes: episodes)
  end

  #def create(conn, %{"episode" => episode_params}) do
  #  changeset = Episode.changeset(%Episode{}, series, episode_params)
  #
  #  case Repo.insert(changeset) do
  #    {:ok, episode} ->
  #      conn
  #      |> put_status(:created)
  #      |> put_resp_header("location", episode_path(conn, :show, episode))
  #      |> render("show.json", episode: episode)
  #    {:error, changeset} ->
  #      conn
  #      |> put_status(:unprocessable_entity)
  #      |> render(Animu.ChangesetView, "error.json", changeset: changeset)
  #  end
  #end

  def show(conn, %{"id" => id}) do
    episode = Repo.get!(Episode, id)
    render(conn, "show.json", episode: episode)
  end

  def update(conn, %{"id" => id, "episode" => episode_params}) do
    episode = Repo.get!(Episode, id)
    changeset = Episode.changeset(episode, episode_params)

    case Repo.update(changeset) do
      {:ok, episode} ->
        render(conn, "show.json", episode: episode)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Animu.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    episode = Repo.get!(Episode, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(episode)

    send_resp(conn, :no_content, "")
  end
end

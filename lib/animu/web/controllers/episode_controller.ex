defmodule Animu.Web.EpisodeController do
  use Animu.Web, :controller

  alias Animu.Media
  alias Animu.Media.Episode

  plug Guardian.Plug.EnsureAuthenticated, handler: Animu.Web.SessionController
  action_fallback Animu.Web.FallbackController

  def index(conn, params) do
    episodes = Media.list_episodes(params)
    render(conn, "index.json", episodes: episodes)
  end

  def create(conn, %{"episode" => episode_params}) do
    with {:ok, %Episode{} = episode} <- Media.create_episode(episode_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", episode_path(conn, :show, episode))
      |> render("show.json", episode: episode)
    end
  end

  def show(conn, %{"id" => id}) do
    episode = Media.get_episode!(id)
    render(conn, "show.json", episode: episode)
  end

  def update(conn, %{"id" => id, "episode" => episode_params}) do
    episode = Media.get_episode!(id)
    with {:ok, %Episode{} = episode} <- Media.update_episode(episode, episode_params) do
      render(conn, "show.json", episode: episode)
    end
  end

  def delete(conn, %{"id" => id}) do
    episode = Media.get_episode!(id)
    with {:ok, %Episode{}} <- Media.delete_episode(episode) do
      send_resp(conn, :no_content, "")
    end
  end
end

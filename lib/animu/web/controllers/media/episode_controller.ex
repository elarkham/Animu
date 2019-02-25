defmodule Animu.Web.EpisodeController do
  use Animu.Web, :controller
  use Expat

  alias Animu.Media
  alias Animu.Media.Anime.Episode

  action_fallback Animu.Web.FallbackController

  ## Patterns

  defpat by_fran(
    %{"franchise_id" => franchise_id,
      "anime_num" => anime_num,
      "num" => ep_num
    }
  )

  defpat by_anime(
    %{"anime_id" => anime_id,
      "num" => ep_num
    }
  )
  #### GET

  ## Index
  def index(conn, params) do
    episodes = Media.list_episodes(params)
    render(conn, "index.json", episodes: episodes)
  end

  ## Show
  def show(conn, %Episode{} = ep) do
    render(conn, "show.json", episode: ep)
  end
  def show(conn, by_fran(fran_id, anime_num, ep_num)) do
    episode = Media.get_episode!(fran_id, anime_num, ep_num)
    show(conn, episode)
  end
  def show(conn, by_anime(anime_id, ep_num)) do
    episode = Media.get_episode!(anime_id, ep_num)
    show(conn, episode)
  end
  def show(conn, %{"id" => id}) do
    episode = Media.get_episode!(id)
    show(conn, episode)
  end

  #### POST/PATCH

  ## Create
  def create(conn, params = %{"episode" => attrs}) do
    opt = params["options"] || %{}
    with {:ok, %Episode{} = ep} <- Media.create_episode(attrs, opt) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", episode_path(conn, :show, ep))
      |> render("show.json", episode: ep)
    end
  end

  ## Update
  def update(conn, ep = %Episode{}, params = %{"episode" => attrs}) do
    opt = params["options"] || %{}
    with {:ok, %Episode{} = ep} <- Media.update_episode(ep, attrs, opt) do
      render(conn, "show.json", episode: ep)
    end
  end
  def update(conn, params = by_fran(id, animu_num, ep_num)) do
    episode = Media.get_episode!(id, animu_num, ep_num)
    update(conn, episode, params)
  end
  def update(conn, params = by_anime(id, ep_num)) do
    episode = Media.get_episode!(id, ep_num)
    update(conn, episode, params)
  end
  def update(conn, params = %{"id" => id}) do
    episode = Media.get_episode!(id)
    update(conn, episode, params)
  end

  #### DELETE

  ## Delete
  def delete(conn, %{"id" => id}) do
    episode = Media.get_episode!(id)
    with {:ok, %Episode{}} <- Media.delete_episode(episode) do
      send_resp(conn, :no_content, "")
    end
  end

end

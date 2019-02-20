defmodule Animu.Media do
  @moduledoc """
  The boundary for the Media domain
  """
  import Ecto.{Query, Changeset}, warn: false

  import Animu.Media.Query
  import Animu.Util.Schema

  alias Animu.Repo
  alias Animu.Media.{Franchise, Anime, Union}
  alias Animu.Media.Anime.{Episode, Video}

  ##
  # Franchise Interactions
  ##

  @doc """
  Returns `%Ecto.Changeset{}` for tracking Franchise changes
  """
  def franchise_changeset(%Franchise{} = franchise, attrs) do
    virtual_fields = [:poster_url, :cover_url]

    franchise
    |> Repo.preload(:anime)
    |> cast(attrs, all_fields(Franchise) ++ virtual_fields)
    |> Franchise.Invoke.summon_images
    |> validate_required([:canon_title, :slug])
    |> unique_constraint(:slug)
  end

  def change_franchise(%Franchise{} = franchise) do
    franchise_changeset(franchise, %{})
  end

  @doc """
  Returns a list of Franchises
  """
  def list_franchises(params \\ %{}) do
    Franchise
    |> build_query(params)
    |> Repo.all()
  end

  @doc """
  Returns single Franchise using it's id or slug

  Raises `Ecto.NoResultsError` if the Franchise does not exist.
  """
  def get_franchise!(id) when is_integer(id) do
    Franchise
    |> Repo.get!(id)
    |> Repo.preload(:anime)
  end
  def get_franchise!(slug) when is_binary(slug) do
    Franchise
    |> Repo.get_by!(slug: slug)
    |> Repo.preload(:anime)
  end

  @doc """
  Creates new Franchise
  """
  def create_franchise(attrs \\ %{}) do
    %Franchise{}
    |> franchise_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a Franchise
  """
  def update_franchise(%Franchise{} = franchise, attrs) do
    franchise
    |> franchise_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Franchise
  """
  def delete_franchise(%Franchise{} = franchise) do
    Repo.delete(franchise)
  end

  ##
  # Anime Interactions
  ##

  @doc """
  Returns all watched Anime with Episodes that have nil Videos
  """
  def all_watched_anime do
    episode_query =
      from e in Episode,
       where: is_nil(e.video),
      select: {e.id, e.number}
    anime_query =
      from s in Anime,
      preload: [episodes: ^episode_query],
        where: s.watch == true,
       select: [:id, :rss_feed, :regex, :directory]

    Repo.all(anime_query)
  end

  @doc """
  Returns a list of Anime
  """
  def list_anime(params \\ %{}) do
    Anime
    |> build_query(params)
    |> Repo.all()
  end

  @doc """
  Returns single Anime using it's id or slug

  Raises `Ecto.NoResultsError` if the Anime does not exist.
  """
  def get_anime!(id) when is_integer(id) do
    Anime
    |> Repo.get!(Anime, id)
    |> Repo.preload(:franchise)
    |> Repo.preload(:episodes)
  end
  def get_anime!(slug) when is_binary(slug) do
    Anime
    |> Repo.get_by!(slug: slug)
    |> Repo.preload(:franchise)
    |> Repo.preload(:episodes)
  end

  @doc """
  Creates new Anime
  """
  def create_anime(attrs, opt \\ []) do
    anime = %Anime{}
    with {:ok, ch, jobs} <- Anime.build(anime, attrs, opt),
            {:ok, anime} <- Repo.insert(ch),
                   anime <- Repo.preload(anime, [:episodes]) do

      Anime.start_golems(anime, jobs)
      {:ok, anime}
    else
      {:error, msg} -> {:error, msg}
      error ->
        msg = "Unexpected Error During Anime Creation: #{inspect(error)}"
        {:error, msg}
    end
  end

  @doc """
  Updates a Anime
  """
  def update_anime(%Anime{} = anime, attrs, opt \\ %{}) do
    with {:ok, ch, jobs} <- Anime.build(anime, attrs, opt),
            {:ok, anime} <- Repo.update(ch),
                   anime <- Repo.preload(anime, [:episodes]) do

      Anime.start_golems(anime, jobs)
      {:ok, anime}
    else
      {:error, msg} -> {:error, msg}
      error ->
        msg = "Unexpected Error During Anime Update: #{inspect(error)}"
        {:error, msg}
    end
  end

  @doc """
  Deletes a Anime
  """
  def delete_anime(%Anime{} = anime) do
    Repo.delete(anime)
  end

  ##
  # Episode Interactions
  ##

  @doc """
  Returns `%Ecto.Changeset{}` for tracking Episode changes
  """
  def episode_changeset(%Episode{} = episode, attrs) do
    episode
    |> cast(attrs, all_fields(Episode, except: [:video]) ++ [:video_path])
    |> validate_required([:name, :number])
    |> foreign_key_constraint(:anime_id)
  end

  def change_episode(%Episode{} = episode) do
    episode_changeset(episode, %{})
  end

  @doc """
  Returns list of Episodes
  """
  def list_episodes(params \\ %{}) do
    Episode
    |> build_query(params)
    |> Repo.all()
    |> Repo.preload(:anime)
  end

  @doc """
  Returns single Episode using it's id

  Raises `Ecto.NoResultsError` if the Episode does not exist.
  """
  def get_episode!(id) do
    Episode
    |> Repo.get!(Episode, id)
    |> Repo.preload(:anime)
  end

  @doc """
  Creates new Episode
  """
  def create_episode(attrs \\ %{}) do
    %Episode{}
    |> episode_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a Epiosde
  """
  def update_episode(%Episode{} = episode, %Video{} = video) do
    episode
    |> cast(%{}, [])
    |> put_embed(:video, video)
    |> Repo.update()
  end
  def update_episode(%Episode{} = episode, attrs) do
    episode
    |> episode_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an Episode
  """
  def delete_episode(%Episode{} = episode) do
    Repo.delete(episode)
  end
end

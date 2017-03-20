defmodule Animu.Media do
  @moduledoc """
  The boundary for the Media system
  """
  import Ecto.{Query, Changeset}, warn: false

  import Animu.Media.Video.Generate
  import Animu.Media.Series.Populate
  import Animu.Media.Query
  import Animu.Schema

  alias Animu.Repo
  alias Animu.Media.{Franchise, Series, Episode}

  ##
  # Franchise Interactions
  ##

  @doc """
  Returns `%Ecto.Changeset{}` for tracking Franchise changes
  """
  def franchise_changeset(%Franchise{} = franchise, attrs) do
    franchise
    |> cast(attrs, all_fields(Franchise))
    |> validate_required([:canon_title, :slug])
  end

  def change_franchise(%Franchise{} = franchise) do
    franchise_changeset(franchise, %{})
  end

  @doc """
  Returns a list of Franchises
  """
  def list_franchises(params) do
    Franchise
      |> build_query(params)
      |> Repo.all()
  end

  @doc """
  Returns single Franchise using it's id or slug

  Raises `Ecto.NoResultsError` if the Franchise does not exist.
  """
  def get_franchise!(id) when is_integer(id) do
    Repo.get!(Franchise, id)
      |> Repo.preload(:series)
  end
  def get_franchise!(slug) when is_binary(slug) do
    Repo.get_by!(Franchise, slug: slug)
      |> Repo.preload(:series)
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
  # Series Interactions
  ##

  @doc """
  Returns `%Ecto.Changeset{}` for tracking Series changes
  """
  def series_changeset(%Series{} = series, attrs) do
    virtual_fields =
      [ :populate,
        :generate_ep_from_kitsu,
        :generate_ep_from_existing,
      ]

    series
    |> Repo.preload(:episodes)
    |> Repo.preload(:franchise)
    |> cast(attrs, all_fields(Series) ++ virtual_fields)
    |> populate_series
    |> unique_constraint(:slug)
    |> validate_required([:canon_title, :slug, :directory])
  end

  def change_series(%Series{} = series) do
    series_changeset(series, %{})
  end

  @doc """
  Returns a list of Series
  """
  def list_series(params) do
    Series
      |> build_query(params)
      |> Repo.all()
  end

  @doc """
  Returns single Series using it's id or slug

  Raises `Ecto.NoResultsError` if the Series does not exist.
  """
  def get_series!(id) when is_integer(id) do
    Repo.get!(Series, id)
      |> Repo.preload(:franchise)
      |> Repo.preload(:episodes)
  end
  def get_series!(slug) when is_binary(slug) do
    Repo.get_by!(Series, slug: slug)
      |> Repo.preload(:franchise)
      |> Repo.preload(:episodes)
  end

  @doc """
  Creates new Series
  """
  def create_series(attrs \\ %{}) do
    %Series{}
    |> series_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a Series
  """
  def update_series(%Series{} = series, attrs) do
    series
    |> series_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Series
  """
  def delete_series(%Series{} = series) do
    Repo.delete(series)
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
    |> validate_required([:title, :number])
    |> foreign_key_constraint(:series_id)
    |> generate_video
  end

  def change_episode(%Episode{} = episode) do
    episode_changeset(episode, %{})
  end

  @doc """
  Returns list of Episodes
  """
  def list_episodes(params) do
    Episode
      |> build_query(params)
      |> Repo.all()
  end

  @doc """
  Returns single Episode using it's id

  Raises `Ecto.NoResultsError` if the Episode does not exist.
  """
  def get_episode!(id), do: Repo.get!(Episode, id)

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

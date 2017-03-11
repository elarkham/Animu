defmodule Animu.Media do
  @moduledoc """
  The boundary for the Media system
  """

  import Ecto.{Query, Changeset}, warn: false
  import Animu.Media.Query
  alias Animu.Repo

  alias Animu.Media.{Franchise, Series, Episode}

  ##
  # Franchise Interactions
  ##

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
    |> Franchise.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a Franchise
  """
  def update_franchise(%Franchise{} = franchise, attrs) do
    franchise
    |> Franchise.changeset(attrs)
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
    |> Series.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a Series
  """
  def update_series(%Series{} = series, attrs) do
    series
    |> Series.changeset(attrs)
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
    |> Episode.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an Epiosde
  """
  def update_episode(%Episode{} = episode, attrs) do
    episode
    |> Episode.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an Episode
  """
  def delete_episode(%Episode{} = episode) do
    Repo.delete(episode)
  end
end

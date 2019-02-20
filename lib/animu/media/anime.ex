defmodule Animu.Media.Anime do
  @moduledoc """
  Stores and builds Anime data
  """
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  import Animu.Util.Schema

  alias Ecto.Changeset
  alias Animu.Repo

  alias Animu.Media.Franchise
  alias Animu.Ecto.Image

  alias Animu.Media.Anime.{Bag, Options}
  alias Animu.Media.Anime.{Episode, Season, Genre}
  alias __MODULE__

  @derive {Poison.Encoder, except: [:__meta__]}
  @timestamps_opts [type: :utc_datetime]
  schema "anime" do

    ## Meta Data
    field :name,           :string
    field :titles,         {:map, :string}
    field :synopsis,       :string
    field :slug,           :string # CI

    field :directory,      :string

    field :cover_image,    Image
    field :poster_image,   Image
    field :gallery,        {:map, :string}

    field :trailers,       {:array, :string}
    field :tags,           {:array, :string}

    many_to_many :genres, Genre,
      join_through: "anime_genres",
      defaults: []

    field :nsfw,           :boolean

    field :age_rating,     :string
    field :age_guide,      :string

    ## External Data
    field :kitsu_rating,   :float
    field :kitsu_id,       :string

    field :mal_id,         :string
    field :tvdb_id,        :string
    field :anidb_id,       :string

    ## Franchise Data
    belongs_to :franchise, Franchise
    field :subtitle,       :string
    field :subtype,        :string # CI
    field :number,         :integer

    ## Episode Data
    has_many   :episodes,  Episode,
      on_replace: :delete,
      defaults: []

    field :episode_count,  :integer
    field :episode_length, :integer

    ## Augur Data
    field :augur,          :boolean
    field :augured_at,     :date

    field :regex,          :string
    field :rss_feed,       :string
    field :subgroup,       :string
    field :quality,        :string

    # Time Data
    many_to_many :season, Season,
      join_through: "anime_seasons",
      defaults: []

    field :airing,     :boolean
    field :airing_at,  :map

    field :start_date, :date
    field :end_date,   :date

    timestamps()
  end

  def build(%Anime{} = anime, params, opt \\ []) do
    with   {:ok, opt} <- Options.parse(opt),
           {:ok, bag} <- Bag.new(anime, params, opt),
                  bag <- Bag.invoke(bag),
         {:ok, attrs} <- Bag.compile(bag),
            {:ok, ch} <- valid_changeset(anime, attrs, bag)
    do
      ch =
        ch
        |> Bag.add_todos(bag)
        |> put_assoc(:episodes, attrs.episodes)

      {:ok, ch, bag.golems}
    else
      {:error, msg} -> {:error, msg}
      error -> {:error, "Unexpected Error: #{inspect(error)}"}
    end
  end

  defp valid_changeset(%Anime{} = anime, attrs, bag) do
    case changeset(anime, attrs) do
      %Changeset{valid?: true} = ch ->
        {:ok, ch}
      ch ->
        {:error, ch} #TODO Traverse Errors
    end
  end

  def changeset(%Anime{} = anime, attrs) do
    anime
    |> Repo.preload(:episodes)
    |> Repo.preload(:franchise)
    |> Repo.preload(:genres)
    |> Repo.preload(:season)
    |> cast(attrs, all_fields(Anime, except: [:poster_image]))
    |> validate_required([:name, :slug, :directory])
    |> unique_constraint(:slug)
  end

  def start_golems(anime, jobs) do
    jobs
    |> Enum.dedup
    |> Enum.map(fn {module, params} ->
         params = params ++ [anime: anime]
         Golem.add(module, params)
       end)
  end

end

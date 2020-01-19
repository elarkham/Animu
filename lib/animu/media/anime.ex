defmodule Animu.Media.Anime do
  @moduledoc """
  Stores and builds Anime data
  """
  use Animu.Ecto.Schema

  alias Animu.Ecto.Image

  alias __MODULE__
  alias Animu.Media
  alias Media.Franchise
  alias Anime.{Bag, Options}
  alias Anime.{Episode, Season, Genre}

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
      join_through: "anime_genre",
      on_replace: :delete,
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
    field :augured_at,     :utc_datetime

    field :regex,          :string
    field :rss_feed,       :string
    field :subgroup,       :string
    field :quality,        :string

    ## Time Data

    many_to_many :season, Season,
      join_through: "anime_season",
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
            {:ok, ch} <- valid_changeset(bag.anime, attrs)
    do
      ch =
        ch
        |> Bag.add_todos(bag)
        |> put_assoc(:episodes, attrs.episodes)

      IO.inspect ch
      {:ok, ch, bag.golems}
    else
      {:error, msg} -> {:error, msg}
      error ->
        {:error, "Unexpected Error: #{inspect(error)}"}
    end
  end

  defp valid_changeset(%Anime{} = anime, attrs) do
    case changeset(anime, attrs) do
      %Changeset{valid?: true} = ch ->
        {:ok, ch}
      ch ->
        errors = Animu.Util.format_errors(ch)
        {:error, errors}
    end
  end

  def changeset(%Anime{} = anime, attrs) do
    anime
    |> cast(attrs, all_fields(Anime))
    |> validate_required([:name, :slug, :directory])
    |> unique_constraint(:slug)
  end

  def bake_golems(anime, jobs) do
    jobs
    |> Enum.dedup
    |> Enum.map(fn {module, params} ->
         params = params ++ [anime: anime]
         Kiln.bake(module, params)
       end)
  end

end

defimpl Inspect, for: Animu.Media.Anime do
  import Inspect.Algebra

  @fields [
    ## Meta
    :name,
    :titles,
    :synopsis,
    :slug,

    :directory,

    :cover_image,
    :poster_image,
    :gallery,

    #:trailers,
    :tags,

    :genres,

    :nsfw,

    :age_rating,
    :age_guide,

    ## External Data
    :kitsu_rating,
    :kitsu_id,

    :mal_id,
    :tvdb_id,
    :anidb_id,

    ## Franchise Data
    :franchise,
    :subtitle,
    :subtype,
    :number,

    ## Episode Data
    :episodes,
    :episode_count,
    :episode_length,

    ## Augur Data
    :augur,
    :augured_at,

    :regex,
    :rss_feed,
    :subgroup,
    :quality,

    ## Time Data
    :season,
    :airing,
    :airing_at,

    :start_date,
    :end_date,
  ]

  def inspect(changeset, opts) do
    list = for attr <- @fields do
      {attr, Map.get(changeset, attr)}
    end

    container_doc("#Anime<", list, ">", opts, fn
      {field, value = %Ecto.Association.NotLoaded{}}, opts ->
        concat(color("#{field}: ", :atom, opts), to_doc(:not_loaded, opts))

      {field, value}, opts -> concat(color("#{field}: ", :atom, opts), to_doc(value, opts))
    end)
  end


  defp to_struct(%{__struct__: struct}, _opts), do: "#" <> Kernel.inspect(struct) <> "<>"
  defp to_struct(other, opts), do: to_doc(other, opts)
end

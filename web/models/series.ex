defmodule Animu.Series do
  use Animu.Web, :model

  import File
  import Animu.SeriesPopulator

  alias Animu.{Repo, Episode, Franchise}
  alias Ecto.Changeset

  @derive {Poison.Encoder, except: [:__meta__]}
  schema "series" do
    field :canon_title,    :string
    field :titles,         {:map, :string}
    field :synopsis,       :string
    field :slug,           :string

    field :cover_image,    {:map, :string}
    field :poster_image,   {:map, :string}
    field :gallery,        {:map, :string}

    field :trailers,       {:array, :string}
    field :tags,           {:array, :string}
    field :genres,         {:array, :string}

    field :age_rating,     :string
    field :nsfw,           :boolean

    field :season_number,  :integer
    field :episode_count,  :integer
    field :episode_length, :integer

    has_many   :episodes,   Episode, defaults: []
    belongs_to :franchise,  Franchise, defaults: %Franchise{}

    field :kitsu_rating,   :float
    field :kitsu_id,       :string

    field :regex,          :string
    field :subgroup,       :string
    field :quality,        :string
    field :rss_feed,       :string
    field :watch,          :boolean, default: false

    field :directory,      :string

    field :started_airing_date,  :date
    field :finished_airing_date, :date

    timestamps()
  end


@required_fields ~w(canon_title slug directory)a

@optional_fields ~w(titles synopsis
                    cover_image poster_image gallery
                    trailers tags genres age_rating nsfw
                    season_number episode_count episode_length
                    kitsu_rating kitsu_id
                    started_airing_date finished_airing_date
                    regex subgroup quality rss_feed watch)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> Repo.preload(:episodes)
    |> cast(params, @required_fields ++ @optional_fields)
    |> populate
    |> validate_required(@required_fields)
  end

  @doc """
  Generates a map that only has fields that are within a "Series" struct.
  Similar to Kernel.struct/2 but without the adom key requirement.
  """
  def scrub_params(params) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields)
    |> apply_changes
  end

  @doc """
  Search given dir for existing episodes
  """
  def search_existing_ep(changeset =
      %Changeset{changes: %{directory: series_path, regex: regex}}) do
    full_path = Application.get_env(:animu, :file_root) <> series_path
    unless dir?(full_path), do: mkdir_p!(full_path)
    regex = Regex.compile!(regex)

    episodes =
      ls!(full_path)
      |> Enum.filter(&(Regex.match?(regex, &1)))
      |> Enum.map(fn(filename) ->
        num =
          Regex.named_captures(regex, filename)["num"]
          |> String.to_integer

        episode_params =
        %{title: "Episode #{num}",
          number: num/1,
          video: filename}
        Episode.changeset(%Episode{}, episode_params)
      end)
    Changeset.put_assoc(changeset, :episodes, episodes)
  end
  def search_existing_ep(changeset), do: changeset

  @doc """
  Ensure series has atleast as many episodes as specified in episode_count
  """
  def fill_with_new_ep(changeset =
      %Changeset{changes: %{episode_count: count, episodes: episodes}}) do

    existing = Map.new(episodes, fn ep -> {ep.changes.number, ep} end)
    new = Map.new(Episode.new(count), fn ep -> {ep.changes.number, ep} end)

    episodes = Map.merge(new, existing) |> Map.values
    Changeset.put_assoc(changeset, :episodes, episodes)
  end
  def fill_with_new_ep(changeset), do: changeset
end

defmodule Animu.Series do
  use Animu.Web, :model

  alias Animu.Repo

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

    has_many   :episodes,   Animu.Episode, defaults: []
    belongs_to :franchise,  Animu.Franchise, defaults: %{}

    field :kitsu_rating,   :float
    field :kitsu_id,       :string

    field :directory,      :string

    field :started_airing_date,  Ecto.DateTime
    field :finished_airing_date, Ecto.DateTime

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> Repo.preload(:episodes)
    |> cast(params, [:canon_title, :titles, :synopsis, :slug,
                     :cover_image, :poster_image, :gallery,
                     :trailers, :tags, :genres,
                     :age_rating, :nsfw,
                     :season_number, :episode_count, :episode_length,
                     :kitsu_rating, :kitsu_id,
                     :started_airing_date, :finished_airing_date,
                     :directory,
                    ])
    |> cast_assoc(:episodes)
    |> validate_required([:canon_title, :slug, :directory])
  end
end

defmodule Animu.Series do
  use Animu.Web, :model

  alias Animu.Repo

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

    has_many   :episodes,   Animu.Episode, defaults: []
    belongs_to :franchise,  Animu.Franchise, defaults: %{}

    field :kitsu_rating,   :float
    field :kitsu_id,       :string

    field :directory,      :string

    field :started_airing_date,  Ecto.DateTime
    field :finished_airing_date, Ecto.DateTime

    timestamps()
  end


@required_fields ~w(canon_title slug directory)a

@optional_fields ~w(titles synopsis
                    cover_image poster_image gallery
                    trailers tags genres age_rating nsfw
                    season_number episode_count episode_length
                    kitsu_rating kitsu_id
                    started_airing_date finished_airing_date)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> Repo.preload(:episodes)
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

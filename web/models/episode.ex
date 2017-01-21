defmodule Animu.Episode do
  use Animu.Web, :model

  alias Animu.{Repo, Series}

  schema "episodes" do
    field :title,         :string
    field :synopsis,      :string
    field :thumbnail,     {:map, :string}
    field :kitsu_id,      :string

    field :number,        :float
    field :season_number, :integer
    field :airdate,       Ecto.DateTime

    belongs_to :series, Series
    #has_many :video, Video

    field :video,     :string
    field :subtitles, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> Repo.preload(:series)
    |> cast(params, [:title, :synopsis, :thumbnail, :kitsu_id,
                     :number, :season_number, :airdate,
                     :video, :subtitles
                   ])
    |> validate_required([:title, :number, :video])
  end

  def changeset_series(struct, series, params \\ %{}) do
    struct
    |> Repo.preload(:series)
    |> cast(params, [:title, :synopsis, :thumbnail, :kitsu_id,
                     :number, :season_number, :airdate,
                     :video, :subtitles,
                    ])
    |> put_assoc(:series, series, required: true)
    |> validate_required([:title, :number, :video])
  end
end

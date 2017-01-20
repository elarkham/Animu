defmodule Animu.Episode do
  use Animu.Web, :model

  schema "episodes" do
    field :title,         :string
    field :synopsis,      :string
    field :thumbnail,     {:map, :string}
    field :kitsu_id,      :string

    field :number,        :float
    field :season_number, :integer
    field :airdate,       Ecto.DateTime

    belongs_to :series, Animu.Series
    #has_many :video, Animu.Video

    field :video,     :string
    field :subtitles, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :synopsis, :thumbnail, :kitsu_id,
                     :number, :season_number, :airdate,
                     :series,
                     :video, :subtitles,
                    ])
    |> cast_assoc(params, [:series])
    |> validate_required([:canon_title, :number])
  end
end

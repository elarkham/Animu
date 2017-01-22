defmodule Animu.Episode do
  use Animu.Web, :model

  alias Animu.{Repo, Series}

  @derive {Poison.Encoder, except: [:__meta__]}
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

  @required_fields ~w(title number video series_id)a
  @optional_fields ~w(synopsis thumbnail kitsu_id season_number airdate
                      subtitles)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> Repo.preload(:series)
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:series_id)
  end
end

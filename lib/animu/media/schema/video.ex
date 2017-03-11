defmodule Animu.Media.Video do
  use Ecto.Schema

  import Ecto.Changeset
  alias __MODULE__, as: Video

  embedded_schema do
    field :title,         :string
    field :synopsis,      :string
    field :thumbnail,     {:map, :string}
    field :kitsu_id,      :string

    field :number,        :float
    field :season_number, :integer
    field :airdate,       :date

    belongs_to :series, Series
    #has_many :video, Video

    field :video,     :string
    field :subtitles, :string

    timestamps()
  end

  @required_fields ~w()a
  @optional_fields ~w()a

  @doc """
  Returns `%Ecto.Changeset{}` for tracking Video changes
  """
  def changeset(%Video{} = video, attrs) do
    video
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def change(%Video{} = video) do
    changeset(video, %{})
  end

end

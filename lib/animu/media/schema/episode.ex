defmodule Animu.Media.Episode do
  use Ecto.Schema

  import Ecto.Changeset

  alias Animu.Media.Series
  alias __MODULE__, as: Episode

  @derive {Poison.Encoder, except: [:__meta__]}
  schema "episodes" do
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

  @required_fields ~w(title number)a
  @optional_fields ~w(synopsis thumbnail kitsu_id season_number airdate
                      subtitles video)a

  @doc """
  Returns `%Ecto.Changeset{}` for tracking Episode changes
  """
  def changeset(%Episode{} = episode, attrs) do
    episode
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:series_id)
  end

  def change(%Episode{} = episode) do
    changeset(episode, %{})
  end

  @doc """
  Creates a list of generic episodes numbering from 1 to $number
  """
  def new(nil), do: []
  def new(episode_count) do
    for i <- 1..episode_count do
      params = %{title: "Episode #{i}", number: (i/1)}
      changeset(%Episode{}, params)
    end
  end
end

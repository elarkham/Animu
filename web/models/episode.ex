defmodule Animu.Episode do
  use Animu.Web, :model

  alias Animu.{Repo, Series}
  alias __MODULE__, as: Episode

  @derive {Poison.Encoder, except: [:__meta__, :series]}
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

  @required_fields ~w(title number series_id)a
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

  @doc """
  Generates a map that only has fields that are within an "Episode" struct.
  Similar to Kernel.struct/2 but without the adom key requirement.
  """
  def scrub_params(params) do
    %Episode{}
    |> cast(params, @required_fields ++ @optional_fields)
    |> apply_changes
    |> Map.from_struct
    |> Map.delete(:__meta__)
  end

  @doc """
  Creates a list of generic episodes numbering from 1 to $number
  """
  def new(nil), do: []
  def new(episode_count) do
    for i <- 1..episode_count do
      %Episode{
        title: "Episode #{i}",
        number: (i/1),
      }
    end
  end

end

defmodule Animu.TVSeries do
  use Animu.Web, :model

  alias __MODULE__

  @derive {Poison.Encoder, only: [:id, :titles, :slug]}

  schema "tvseries" do
    field :titles,             :map
    field :slug,               :string

    field :poster_image,       :map
    field :cover_image,        :map
    field :gallery,            :map

    field :description,        :string
    field :genres,             {:array, :string}
    field :age_rating,         :string
    field :hummingbird_rating, :float
    field :trailers,           {:array, :string}
    field :tags,               {:array, :string}

    field :season_number,      :integer
    field :episode_count,      :integer
    field :episode_length,     :float

    belongs_to :franchise, Animu.Franchise
    has_many :episodes,    Animu.Episode

    field :finished_airing, Ecto.Date
    field :started_airing,  Ecto.Date
    timestamps
  end

  @required_fields ~w(titles slug franchise)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:titles)
    |> unique_constraint(:slug)
  end
end

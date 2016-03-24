defmodule Animu.Episode do
  use Animu.Web, :model

  alias __MODULE__

  @derive {Poison.Encoder, only: [:id, :title, :slug, :number]}

  schema "episodes" do
    field :title, :string
    field :number, :integer
    field :slug, :string

    field :description, :string
    field :season_number, :integer

    belongs_to :tv_series, Animu.TVSeries
    has_one :video, Animu.Video

    field :airdate, Ecto.DateTime
    timestamps
  end

  @required_fields ~w(title number slug)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:title)
    |> unique_constraint(:number)
    |> unique_constraint(:slug)
  end
end

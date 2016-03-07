defmodule Animu.Franchise do
  use Animu.Web, :model

  alias __MODULE__

  @derive {Poison.Encoder, only: [:id, :titles, :slug]}

  schema "franchises" do
    field :titles,        :map
    field :creator,       :string
    field :description,   :string
    field :slug,          :string

    field :cover_image,   :map
    field :poster_image,  :map
    field :gallery,       :map

    field :trailers,      {:array, :string}
    field :tags,          {:array, :string}

    has_many :tv_series, Animu.TVSeries

    field :date_released, Ecto.DateTime
    timestamps
  end

  @required_fields ~w(slug titles)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

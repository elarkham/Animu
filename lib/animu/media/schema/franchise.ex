defmodule Animu.Media.Franchise do
  use Ecto.Schema

  import Ecto.Changeset

  alias Animu.Media.Series
  alias __MODULE__, as: Franchise

  @derive {Poison.Encoder, except: [:__meta__]}
  schema "franchises" do
    field :canon_title,   :string
    field :titles,        :map
    field :creator,       :string
    field :synopsis,      :string
    field :slug,          :string

    field :cover_image,   :map
    field :poster_image,  :map
    field :gallery,       :map

    field :trailers,      {:array, :string}
    field :tags,          {:array, :string}

    has_many :series, Series

    field :date_released, :date

    timestamps()
  end


  @required_fields ~w(canon_title slug)a
  @optional_fields ~w(titles creator synopsis cover_image poster_image
                      gallery trailers tags)a


  @doc """
  Returns `%Ecto.Changeset{}` for tracking Franchise changes
  """
  def changeset(%Franchise{} = franchise, attrs) do
    franchise
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def change(%Franchise{} = franchise) do
    changeset(franchise, %{})
  end
end

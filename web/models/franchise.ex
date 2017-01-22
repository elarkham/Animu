defmodule Animu.Franchise do
  use Animu.Web, :model

  alias Animu.Repo

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

    has_many :series, Animu.Series

    field :date_released, Ecto.DateTime

    timestamps()
  end


  @required_fields ~w(canon_title slug)a
  @optional_fields ~w(titles creator synopsis cover_image poster_image
                      gallery trailers tags)a


  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> Repo.preload(:series)
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def scrub_params(params) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields)
    |> apply_changes
    |> Map.from_struct
    |> Map.delete(:__meta__)
  end
end

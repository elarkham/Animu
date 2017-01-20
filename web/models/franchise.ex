defmodule Animu.Franchise do
  use Animu.Web, :model

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

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:canon_title, :titles, :creator, :synopsis, :slug,
                     :cover_image, :poster_image,
                     :gallery, :trailers, :tags,
                    ])
    |> validate_required([:canon_title, :slug])
  end
end

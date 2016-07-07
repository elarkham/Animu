defmodule Animu.Franchise do
  use Animu.Web, :model

  schema "franchises" do
    field :titles, :map
    field :creator, :string
    field :description, :string
    field :slug, :string
    field :cover_image, :map
    field :poster_image, :map
    field :gallery, :map
    field :trailers, {:array, :string}
    field :tags, {:array, :string}

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:titles, :creator, :description, :slug, :cover_image, :poster_image, :gallery, :trailers, :tags])
    |> validate_required([:titles, :creator, :description, :slug, :cover_image, :poster_image, :gallery, :trailers, :tags])
  end
end

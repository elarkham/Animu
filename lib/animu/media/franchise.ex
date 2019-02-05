defmodule Animu.Media.Franchise do
  use Ecto.Schema

  alias Animu.Media.Series
  alias __MODULE__, as: Franchise

  @derive {Poison.Encoder, except: [:__meta__]}
  schema "franchises" do
    field :titles,        :map
    field :canon_title,   :string
    field :slug,          :string

    field :creator,       :string
    field :synopsis,      :string

    field :directory,     :string

    field :cover_image,   Image
    field :poster_image,  Image

    field :tags,          {:array, :string}

    has_many :series, Series, default: []

    # TODO maybe
    many_to_many :related, Franchise,
      join_through: "related_franchises"
      default: []

    timestamps()
  end

end

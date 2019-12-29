defmodule Animu.Media.Franchise do
  @moduledoc """
  Organizes Anime by franchise
  """
  use Animu.Ecto.Schema


  alias Animu.Ecto.Image
  alias Animu.Media.Anime
  alias __MODULE__

  schema "franchise" do
    field :name,          :string, null: false
    field :titles,        :map
    field :slug,          :string, null: false

    field :creator,       :string
    field :synopsis,      :string

    field :directory,     :string

    field :cover_image,   Image
    field :poster_image,  Image

    field :tags,          {:array, :string}

    has_many :anime, Anime

    # TODO
    #many_to_many :related, Franchise.Related,
    #  join_through: "related_franchises"

    timestamps()
  end

end

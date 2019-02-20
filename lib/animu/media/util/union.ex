defmodule Animu.Media.Union do
  @moduledoc """
  Mixes Series and Franchise querys
  """
  use Ecto.Schema

  import Ecto.{Query, Changeset}, warn: false
  import Animu.Util.Schema
  alias __MODULE__, as: Union

  embedded_schema do
    field :canon_title,   :string
    field :titles,        :map
    field :synopsis,      :string
    field :slug,          :string

    field :directory

    field :poster_image,   :map
    field :trailers,      {:array, :string}
    field :tags,          {:array, :string}
  end

  def build_select(query, type) do
    select(query, [m],
      %{
        canon_title: m.canon_title,
        titles: m.titles,
        synopsis: m.synopsis,
        slug: m.slug,

        directory: m.directory,

        poster_image: m.poster_image,
        trailers: m.trailers,
        tags: m.tags,

        type: ^type
      })
  end
end


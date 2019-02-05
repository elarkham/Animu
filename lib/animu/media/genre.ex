defmodule Animu.Media.Genre do
  use Ecto.Schema

  import Ecto.Changeset
  import Animu.Util.Schema

  alias Animu.Media.Series
  alias Animu.Util.Image

  alias __MODULE__, as: Genre

  @derive {Poison.Encoder, except: [:__meta__]}
  schema "genre" do
    field :title,       :string # CS Required
    field :slug,        :string # CI Required
    field :nsfw,        :bool

    field :description, :string

    field :poster, Image

    many_to_many :series, Series,
      join_through: "series_genres",
      defaults: []

    timestamps()
  end

  @required [:title, :slug]

  def changeset(%Genre{}, attrs) do
    genre
    |> cast(attrs, all_fields(Genre))
    |> validate_required(@required)
    |> unique_constraint(:title)
    |> unique_constraint(:slug)
  end

  def insert_or_get_all(genres) do
    slugs = Enum.map(genres, &apply_changes/1)
    resolve = :replace_all_except_primary_key
    Repo.insert_all(genres, on_conflict: resolve)
    Repo.all(from g in Genre, where: g.slug in ^slugs)
  end

  #def parse_list(titles) do
  #  titles
  #  |> Enum.reject(& &1 == "")
  #  |> Enum.map(&String.downcase/2)
  #  |> insert_or_get_all/1
  #end

end

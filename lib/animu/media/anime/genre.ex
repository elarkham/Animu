defmodule Animu.Media.Anime.Genre do
  @moduledoc """
  Organizes Anime by genre, mostly ones pulled from kitsu.io
  """
  use Animu.Ecto.Schema

  alias Animu.Repo
  alias Animu.Ecto.Image
  alias Animu.Media.Anime

  alias __MODULE__

  schema "genre" do
    field :name,        :string # CS Required
    field :slug,        :string # CI Required
    field :nsfw,        :boolean

    field :description, :string
    field :poster, Image

    field :kitsu_id, :string

    many_to_many :anime, Anime,
      join_through: "anime_genre",
      defaults: []
  end

  @required [:name, :slug]

  def changeset(%Genre{} = genre, attrs) do
    genre
    |> cast(attrs, all_fields(Genre))
    |> validate_required(@required)
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end

  def insert_or_get_all(genres) do
    slugs   = Enum.map(genres, &(&1.slug))
    opt = [on_conflict: :nothing]
    Repo.insert_all(Genre, genres, opt)
    Repo.all(from g in Genre, where: g.slug in ^slugs)
  end

  #def parse_list(titles) do
  #  titles
  #  |> Enum.reject(& &1 == "")
  #  |> Enum.map(&String.downcase/2)
  #  |> insert_or_get_all/1
  #end

end

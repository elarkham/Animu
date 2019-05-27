defmodule Animu.Web.GenreView do
  use Animu.Web, :view

  alias __MODULE__
  alias Animu.Web.AnimeView

  def render("index.json", %{genres: genres}) do
    %{genres: render_many(genres, GenreView, "genres.json")}
  end

  def render("show.json", %{genre: genre}) do
    %{genre: render_one(genre, GenreView, "genre.json")}
  end

  def render("genres.json", %{genre: genre}) do
    %{id: genre.id,
      name: genre.name,
      slug: genre.slug,

      nsfw: genre.nsfw,
      description: genre.description,

      kitsu_id: genre.kitsu_id,
    }
  end

  def render("genre_slugs.json", %{genre: genre}) do
    genre.slug
  end

  def render("genre.json", %{genre: genre}) do
    %{id: genre.id,
      name: genre.name,
      slug: genre.slug,

      nsfw: genre.nsfw,
      description: genre.description,

      kitsu_id: genre.kitsu_id,

      anime: render_many(genre.anime, AnimeView, "anime_many.json"),
    }
  end

end

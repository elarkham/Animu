defmodule Animu.Web.AnimeView do
  use Animu.Web, :view

  alias __MODULE__, as: AnimeView
  alias Animu.Web.{GenreView, SeasonView, EpisodeView}

  def render("index.json", %{anime: anime}) do
    %{anime: render_many(anime, AnimeView, "anime_many.json")}
  end

  def render("show.json", %{anime: anime}) do
    %{anime: render_one(anime, AnimeView, "anime.json")}
  end

  def render("anime_many.json", %{anime: anime}) do

    genres =
      if Ecto.assoc_loaded?(anime.genres) do
          render_many(anime.genres, GenreView, "genre_slugs.json")
      else
        nil
      end

    season =
      if Ecto.assoc_loaded?(anime.season) do
          render_many(anime.season, SeasonView, "season_slugs.json")
      else
        nil
      end

    %{id: anime.id,

      ## Meta Data
      name: anime.name,
      titles: anime.titles,
      synopsis: anime.synopsis,
      slug: anime.slug,

      directory: anime.directory,

      cover_image: anime.cover_image,
      poster_image: anime.poster_image,
      gallery: anime.gallery,

      trailers: anime.trailers,
      tags: anime.tags,

      genres: genres,

      nsfw: anime.nsfw,

      age_rating: anime.age_rating,
      age_guide: anime.age_guide,

      ## External Data
      kitsu_rating: anime.kitsu_rating,
      kitsu_id: anime.kitsu_id,

      mal_id: anime.mal_id,
      tvdb_id: anime.tvdb_id,
      anidb_id: anime.anidb_id,

      ## Franchise Data
      subtitle: anime.subtitle,
      subtype: anime.subtype,
      number: anime.number,

      ## Episode Data
      episode_count: anime.episode_count,
      episode_length: anime.episode_length,

      ## Augur Data
      augur: anime.augur,
      augured_at: anime.augured_at,

      regex: anime.regex,
      rss_feed: anime.rss_feed,
      subgroup: anime.subgroup,
      quality: anime.quality,

      # Time Data
      season: season,

      airing: anime.airing,
      airing_at: anime.airing_at,

      start_date: anime.start_date,
      end_date: anime.end_date,

      #inserted_at: anime.inserted_at,
      #updated_at: anime.updated_at,
    }
    |> Enum.filter(fn {_k, v} -> v != nil end)
    |> Map.new()
  end

  def render("anime.json", %{anime: anime}) do
    %{id: anime.id,

      ## Meta Data
      name: anime.name,
      titles: anime.titles,
      synopsis: anime.synopsis,
      slug: anime.slug,

      directory: anime.directory,

      cover_image: anime.cover_image,
      poster_image: anime.poster_image,
      gallery: anime.gallery,

      trailers: anime.trailers,
      tags: anime.tags,

      genres: render_many(anime.genres, GenreView, "genre_slugs.json"),

      nsfw: anime.nsfw,

      age_rating: anime.age_rating,
      age_guide: anime.age_guide,

      ## External Data
      kitsu_rating: anime.kitsu_rating,
      kitsu_id: anime.kitsu_id,

      mal_id: anime.mal_id,
      tvdb_id: anime.tvdb_id,
      anidb_id: anime.anidb_id,

      ## Franchise Data
      #franchise: anime.franchise,
      subtitle: anime.subtitle,
      subtype: anime.subtype,
      number: anime.number,

      ## Episode Data
      episodes: render_many(anime.episodes, EpisodeView, "episodes.json"),

      episode_count: anime.episode_count,
      episode_length: anime.episode_length,

      ## Augur Data
      augur: anime.augur,
      augured_at: anime.augured_at,

      regex: anime.regex,
      rss_feed: anime.rss_feed,
      subgroup: anime.subgroup,
      quality: anime.quality,

      # Time Data
      season: render_many(anime.season, SeasonView, "seasons.json"),

      airing: anime.airing,
      airing_at: anime.airing_at,

      start_date: anime.start_date,
      end_date: anime.end_date,

      inserted_at: anime.inserted_at,
      updated_at: anime.updated_at,
    }
    |> Enum.filter(fn {_k, v} -> v != nil end)
    |> Map.new()
  end

end

defmodule Animu.Web.AnimeView do
  use Animu.Web, :view

  alias __MODULE__, as: AnimeView
  alias Animu.Web.EpisodeView

  def render("index.json", %{anime: anime}) do
    %{anime: render_many(anime, AnimeView, "anime_many.json")}
  end

  def render("show.json", %{anime: anime}) do
    %{anime: render_one(anime, AnimeView, "anime.json")}
  end

  def render("anime_many.json", %{anime: anime}) do
    %{id: anime.id,
      canon_title: anime.canon_title,
      titles: anime.titles,
      synopsis: anime.synopsis,
      slug: anime.slug,

      cover_image: anime.cover_image,
      poster_image: anime.poster_image,
      gallery: anime.gallery,

      trailers: anime.trailers,
      tags: anime.tags,
      genres: anime.genres,

      age_rating: anime.age_rating,
      nsfw: anime.nsfw,

      season_number: anime.season_number,
      episode_count: anime.episode_count,
      episode_length: anime.episode_length,

      kitsu_rating: anime.kitsu_rating,
      kitsu_id: anime.kitsu_id,

      regex: anime.regex,
      subgroup: anime.subgroup,
      quality: anime.quality,
      rss_feed: anime.rss_feed,
      watch: anime.watch,

      directory: anime.directory,

      started_airing_date: anime.started_airing_date,
      finished_airing_date: anime.finished_airing_date,

      inserted_at: anime.inserted_at,
      updated_at:  anime.updated_at,
    }
  end

  def render("anime.json", %{anime: anime}) do
    %{id: anime.id,
      canon_title: anime.canon_title,
      titles: anime.titles,
      synopsis: anime.synopsis,
      slug: anime.slug,

      cover_image: anime.cover_image,
      poster_image: anime.poster_image,
      gallery: anime.gallery,

      trailers: anime.trailers,
      tags: anime.tags,
      genres: anime.genres,

      age_rating: anime.age_rating,
      nsfw: anime.nsfw,

      season_number: anime.season_number,
      episode_count: anime.episode_count,
      episode_length: anime.episode_length,

      episodes: render_many(anime.episodes, EpisodeView, "episodes.json"),

      kitsu_rating: anime.kitsu_rating,
      kitsu_id: anime.kitsu_id,

      regex: anime.regex,
      subgroup: anime.subgroup,
      quality: anime.quality,
      rss_feed: anime.rss_feed,
      watch: anime.watch,

      directory: anime.directory,

      started_airing_date: anime.started_airing_date,
      finished_airing_date: anime.finished_airing_date,

      inserted_at: anime.inserted_at,
      updated_at:  anime.updated_at,
    }
  end

end

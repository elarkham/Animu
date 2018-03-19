defmodule Animu.Web.SeriesView do
  use Animu.Web, :view

  alias __MODULE__, as: SeriesView
  alias Animu.Web.EpisodeView

  def render("index.json", %{series: series}) do
    %{series: render_many(series, SeriesView, "series_many.json")}
  end

  def render("show.json", %{series: series}) do
    %{series: render_one(series, SeriesView, "series.json")}
  end

  def render("series_many.json", %{series: series}) do
    %{id: series.id,
      canon_title: series.canon_title,
      titles: series.titles,
      synopsis: series.synopsis,
      slug: series.slug,

      cover_image: series.cover_image,
      poster_image: series.poster_image,
      gallery: series.gallery,

      trailers: series.trailers,
      tags: series.tags,
      genres: series.genres,

      age_rating: series.age_rating,
      nsfw: series.nsfw,

      season_number: series.season_number,
      episode_count: series.episode_count,
      episode_length: series.episode_length,

      kitsu_rating: series.kitsu_rating,
      kitsu_id: series.kitsu_id,

      regex: series.regex,
      subgroup: series.subgroup,
      quality: series.quality,
      rss_feed: series.rss_feed,
      watch: series.watch,

      directory: series.directory,

      started_airing_date: series.started_airing_date,
      finished_airing_date: series.finished_airing_date,

      inserted_at: series.inserted_at,
      updated_at:  series.updated_at,
    }
  end

  def render("series.json", %{series: series}) do
    %{id: series.id,
      canon_title: series.canon_title,
      titles: series.titles,
      synopsis: series.synopsis,
      slug: series.slug,

      cover_image: series.cover_image,
      poster_image: series.poster_image,
      gallery: series.gallery,

      trailers: series.trailers,
      tags: series.tags,
      genres: series.genres,

      age_rating: series.age_rating,
      nsfw: series.nsfw,

      season_number: series.season_number,
      episode_count: series.episode_count,
      episode_length: series.episode_length,

      episodes: render_many(series.episodes, EpisodeView, "episodes.json"),

      kitsu_rating: series.kitsu_rating,
      kitsu_id: series.kitsu_id,

      regex: series.regex,
      subgroup: series.subgroup,
      quality: series.quality,
      rss_feed: series.rss_feed,
      watch: series.watch,

      directory: series.directory,

      started_airing_date: series.started_airing_date,
      finished_airing_date: series.finished_airing_date,

      inserted_at: series.inserted_at,
      updated_at:  series.updated_at,
    }
  end

end

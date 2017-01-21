defmodule Animu.SeriesView do
  use Animu.Web, :view

  def render("index.json", %{series: series}) do
    %{data: render_many(series, Animu.SeriesView, "series.json")}
  end

  def render("show.json", %{series: series}) do
    %{data: render_one(series, Animu.SeriesView, "series.json")}
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

      episodes: series.episodes,

      kitsu_rating: series.kitsu_rating,
      kitsu_id: series.kitsu_id,

      directory: series.directory,

      started_airing_date: series.started_airing_date,
      finished_airing_date: series.finished_airing_date,
    }
  end
end

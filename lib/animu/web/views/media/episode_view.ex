defmodule Animu.Web.EpisodeView do
  use Animu.Web, :view

  alias __MODULE__, as: EpisodeView
  alias Animu.Web.SeriesView

  def render("index.json", %{episodes: episodes}) do
    %{episodes: render_many(episodes, EpisodeView, "episode_index.json")}
  end

  def render("show.json", %{episode: episode}) do
    %{episode: render_one(episode, EpisodeView, "episode.json")}
  end

def render("episode_index.json", %{episode: episode}) do
    %{id: episode.id,
      title: episode.title,
      synopsis: episode.synopsis,
      thumbnail: episode.thumbnail,
      kitsu_id: episode.kitsu_id,

      number: episode.number,
      season_number: episode.season_number,
      airdate: episode.airdate,

      series: %{
        id: episode.series.id,
        slug: episode.series.slug,
        canon_title: episode.series.canon_title,
      },

      video: episode.video,
    }
  end

  def render("episodes.json", %{episode: episode}) do
    %{id: episode.id,
      title: episode.title,
      synopsis: episode.synopsis,
      thumbnail: episode.thumbnail,
      kitsu_id: episode.kitsu_id,

      number: episode.number,
      season_number: episode.season_number,
      airdate: episode.airdate,

      video: episode.video,
    }
  end

  def render("episode.json", %{episode: episode}) do
    %{id: episode.id,
      title: episode.title,
      synopsis: episode.synopsis,
      thumbnail: episode.thumbnail,
      kitsu_id: episode.kitsu_id,

      number: episode.number,
      season_number: episode.season_number,
      airdate: episode.airdate,

      series: render_one(episode.series, SeriesView, "series_many.json"),
      video: episode.video,
    }
  end
end

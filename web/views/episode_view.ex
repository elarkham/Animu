defmodule Animu.EpisodeView do
  use Animu.Web, :view

  def render("index.json", %{episodes: episodes}) do
    %{data: render_many(episodes, Animu.EpisodeView, "episode.json")}
  end

  def render("show.json", %{episode: episode}) do
    %{data: render_one(episode, Animu.EpisodeView, "episode.json")}
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

      video: episode.video,
      subtitles: episode.subtitles,
    }
  end
end

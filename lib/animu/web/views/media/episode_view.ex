defmodule Animu.Web.EpisodeView do
  use Animu.Web, :view

  alias __MODULE__, as: EpisodeView
  alias Animu.Web.AnimeView

  def render("index.json", %{episodes: episodes}) do
    %{episodes: render_many(episodes, EpisodeView, "episode_index.json")}
  end

  def render("show.json", %{episode: episode}) do
    %{episode: render_one(episode, EpisodeView, "episode.json")}
  end

  def render("episode_index.json", %{episode: episode}) do
    %{id: episode.id,
      name: episode.name,
      titles: episode.titles,
      synopsis: episode.synopsis,

      number: episode.number,
      rel_number: episode.rel_number,

      airdate: episode.airdate,
      augured_at: episode.augured_at,

      kitsu_id: episode.kitsu_id,

      anime: %{
        id: episode.anime.id,
        slug: episode.anime.slug,
        name: episode.anime.name,
      },

      video: episode.video,
    }
  end

  def render("episodes.json", %{episode: episode}) do
    %{id: episode.id,
      name: episode.name,
      titles: episode.titles,
      synopsis: episode.synopsis,

      number: episode.number,
      rel_number: episode.rel_number,

      airdate: episode.airdate,
      augured_at: episode.augured_at,

      kitsu_id: episode.kitsu_id,

      video: episode.video,
    }
  end

  def render("episode.json", %{episode: episode}) do
    %{id: episode.id,
      name: episode.name,
      titles: episode.titles,
      synopsis: episode.synopsis,

      number: episode.number,
      rel_number: episode.rel_number,

      airdate: episode.airdate,
      augured_at: episode.augured_at,

      kitsu_id: episode.kitsu_id,

      anime: render_one(episode.anime, AnimeView, "anime_many.json"),
      video: episode.video,
    }
  end

end

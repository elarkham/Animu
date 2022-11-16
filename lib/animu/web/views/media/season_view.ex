defmodule Animu.Web.SeasonView do
  use Animu.Web, :view

  alias __MODULE__
  alias Animu.Web.AnimeView

  def render("index.json", %{seasons: seasons}) do
    %{seasons: render_many(seasons, SeasonView, "seasons.json")}
  end

  def render("show.json", %{season: season}) do
    %{season: render_one(season, SeasonView, "season.json")}
  end

  def render("seasons.json", %{season: season}) do
    season = %{season | anime:
      case season.anime do
        %{}  -> []
         any -> any
      end
    }

    %{id: season.id,
      year: season.year,
      cour: season.cour,

      name: season.name,
      slug: season.slug,
      sort: season.sort,

      anime: season.anime,
    }
  end

  def render("season_slugs.json", %{season: season}) do
    %{slug: season.slug}
  end

  def render("season.json", %{season: season}) do
    %{id: season.id,
      year: season.year,
      cour: season.cour,

      name: season.name,
      slug: season.slug,
      sort: season.sort,

      anime: render_many(season.anime, AnimeView, "anime_many.json"),
    }
  end

end

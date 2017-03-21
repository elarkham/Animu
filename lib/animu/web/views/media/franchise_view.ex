defmodule Animu.Web.FranchiseView do
  use Animu.Web, :view

  alias __MODULE__, as: FranchiseView
  alias Animu.Web.SeriesView

  def render("index.json", %{franchises: franchises}) do
    %{franchises: render_many(franchises, FranchiseView, "franchises.json")}
  end

  def render("show.json", %{franchise: franchise}) do
    %{franchises: render_one(franchise, FranchiseView, "franchise.json")}
  end

  def render("franchises.json", %{franchise: franchise}) do
    %{id: franchise.id,
      canon_title: franchise.canon_title,
      titles: franchise.titles,
      creator: franchise.creator,
      synopsis: franchise.synopsis,
      slug: franchise.slug,

      cover_image: franchise.cover_image,
      poster_image: franchise.poster_image,
      gallery: franchise.gallery,

      trailers: franchise.trailers,
      tags: franchise.tags,
    }
  end

  def render("franchise.json", %{franchise: franchise}) do
    %{id: franchise.id,
      canon_title: franchise.canon_title,
      titles: franchise.titles,
      creator: franchise.creator,
      synopsis: franchise.synopsis,
      slug: franchise.slug,

      cover_image: franchise.cover_image,
      poster_image: franchise.poster_image,
      gallery: franchise.gallery,

      series: render_many(franchise.series, SeriesView, "series_many.json"),

      trailers: franchise.trailers,
      tags: franchise.tags,
    }
  end
end

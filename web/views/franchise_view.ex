defmodule Animu.FranchiseView do
  use Animu.Web, :view

  def render("index.json", %{franchises: franchises}) do
    %{data: render_many(franchises, Animu.FranchiseView, "franchise.json")}
  end

  def render("show.json", %{franchise: franchise}) do
    %{data: render_one(franchise, Animu.FranchiseView, "franchise.json")}
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

      series: franchise.series,

      trailers: franchise.trailers,
      tags: franchise.tags,
    }
  end
end

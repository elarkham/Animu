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
      titles: franchise.titles,
      creator: franchise.creator,
      description: franchise.description,
      slug: franchise.slug,
      cover_image: franchise.cover_image,
      poster_image: franchise.poster_image,
      gallery: franchise.gallery,
      trailers: franchise.trailers,
      tags: franchise.tags}
  end
end

defmodule Animu.TVSeriesTest do
  use Animu.ModelCase

  alias Animu.TVSeries

  @valid_attrs %{age_rating: "some content", cover_image: %{}, description: "some content", episode_count: 42, episode_length: "120.5", finished_airing: "2010-04-17", gallery: %{}, genres: [], hummingbird_rating: "120.5", poster_image: %{}, season_number: 42, slug: "some content", started_airing: "2010-04-17", tags: [], titles: %{}, trailers: []}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = TVSeries.changeset(%TVSeries{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = TVSeries.changeset(%TVSeries{}, @invalid_attrs)
    refute changeset.valid?
  end
end

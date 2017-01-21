defmodule Animu.SeriesTest do
  use Animu.ModelCase

  alias Animu.Series

  @valid_attrs %{
      canon_title: "some title",
      titles: %{},
      synopsis: "some content",
      slug: "some-slug",

      cover_image: %{},
      poster_image: %{},
      gallery: %{},

      trailers: [],
      tags: [],
      genres: [],

      age_rating: "PG",
      nsfw: false,

      season_number: 1,
      episode_count: 12,
      episode_length: 23,

      kitsu_rating: 3.231,
      kitsu_id: "id",

      directory: "/videos/series",
    }

  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Series.changeset(%Series{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Series.changeset(%Series{}, @invalid_attrs)
    refute changeset.valid?
  end
end

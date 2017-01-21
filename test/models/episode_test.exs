defmodule Animu.EpisodeTest do
  use Animu.ModelCase

  alias Animu.{Episode, Series, Repo}

  @valid_attrs %{
    title: "some title",
    synopsis: "some content",
    thumbnail: %{},
    kitsu_id: "id",

    number: 5.5,
    season_number: 1,

    video: "/videos/video.mp4",
    subtitles: "/videos/video.ssa",
  }

  @invalid_attrs %{}

  test "changeset with valid attributes" do
    # Create Series and insert
    series = %{id: 1, canon_title: "some title", slug: "old-slug", directory: "/videos/series"}
    series = Series.changeset(%Series{}, series) |> Repo.insert!

    # Insert Episode into Series manually
    changeset = Episode.changeset_series(%Episode{}, series, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Episode.changeset(%Episode{}, @invalid_attrs)
    refute changeset.valid?
  end
end

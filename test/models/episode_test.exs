defmodule Animu.EpisodeTest do
  use Animu.ModelCase

  alias Animu.Episode

  @valid_attrs %{airdate: "2010-04-17 14:00:00", description: "some content", number: 42, season_number: 42, slug: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Episode.changeset(%Episode{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Episode.changeset(%Episode{}, @invalid_attrs)
    refute changeset.valid?
  end
end

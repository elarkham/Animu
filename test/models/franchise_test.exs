defmodule Animu.FranchiseTest do
  use Animu.ModelCase

  alias Animu.Franchise

  @valid_attrs %{cover_image: %{}, creator: "some content", description: "some content", gallery: %{}, poster_image: %{}, slug: "some content", tags: [], titles: %{}, trailers: []}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Franchise.changeset(%Franchise{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Franchise.changeset(%Franchise{}, @invalid_attrs)
    refute changeset.valid?
  end
end
defmodule Animu.FranchiseTest do
  use Animu.ModelCase

  alias Animu.Franchise

  @valid_attrs %{cover_image: %{}, creator: "some content", date_released: "2010-04-17 14:00:00", description: "some content", gallery: %{}, poster_image: %{}, slug: "some content", titles: %{}}
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

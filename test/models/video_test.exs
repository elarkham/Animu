defmodule Animu.VideoTest do
  use Animu.ModelCase

  alias Animu.Video

  @valid_attrs %{duration: "120.5", filename: "some content", format_name: "some content", path: "some content", quality: "some content", size: 42, stream_count: 42, thumbnail: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Video.changeset(%Video{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Video.changeset(%Video{}, @invalid_attrs)
    refute changeset.valid?
  end
end

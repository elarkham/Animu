defmodule Animu.SubtitleTest do
  use Animu.ModelCase

  alias Animu.Subtitle

  @valid_attrs %{audio_stream_index: 42, fonts: [], path: "some content", type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Subtitle.changeset(%Subtitle{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Subtitle.changeset(%Subtitle{}, @invalid_attrs)
    refute changeset.valid?
  end
end

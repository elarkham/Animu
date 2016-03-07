defmodule Animu.VideoCodecTest do
  use Animu.ModelCase

  alias Animu.VideoCodec

  @valid_attrs %{bitrate: 42, codec_name: "some content", height: 42, profile: "some content", stream_index: 42, width: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = VideoCodec.changeset(%VideoCodec{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = VideoCodec.changeset(%VideoCodec{}, @invalid_attrs)
    refute changeset.valid?
  end
end

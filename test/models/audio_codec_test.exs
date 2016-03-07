defmodule Animu.AudioCodecTest do
  use Animu.ModelCase

  alias Animu.AudioCodec

  @valid_attrs %{bitrate: 42, channel_layout: "some content", channels: 42, codec_name: "some content", disposition: "some content", language: "some content", profile: "some content", stream_index: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = AudioCodec.changeset(%AudioCodec{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = AudioCodec.changeset(%AudioCodec{}, @invalid_attrs)
    refute changeset.valid?
  end
end

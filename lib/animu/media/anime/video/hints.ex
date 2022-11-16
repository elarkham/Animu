defmodule Animu.Media.Anime.Video.Hints do

  @regex ~r/\[(?<subgroup>.+)\][\s|_](?<name>.+)[\s-\s|_-_|_](?<num>\d+)[\s|_](:?\(.*\)[\s|_])?(?<attr>\[.+\])*\.(?<ext>.+)/

  @resolutions [
    "1080p",
    "1080i",
    "BD 1080p",

    "720p",
    "480p",
  ]

  def parse_video_name(name) do
    case Regex.named_captures(@regex, name) do
      nil -> nil
      map ->
        {res, attr} = parse_attr(map["attr"])
        map
        |> Map.put("res", res)
        |> Map.put("attr", attr)
    end
  end

  def parse_attr(str) do
    attr =
      str
      |> String.replace("[", "")
      |> String.split("]", trim: true)

    case parse_resolution(hd(attr)) do
      nil -> {nil, attr}
      res -> {res, tl(attr)}
    end
  end

  def parse_resolution(str) do
    if Enum.member?(@resolutions, str) do
      str
    else
      nil
    end
  end

  def extract_subgroup(name) do
    parse_video_name(name)["subgroup"]
  end

  ################################
  #   Subgroup Transcode Hints   #
  ################################

  # Assumes MP4
  defp ffmpeg_defaults, do: [
    # Video
    "-vcodec", "libx264",
    "-pix_fmt", "yuv420p",
    #"-profile:v", "baseline", # For Max Compat
    "-preset", "slow",
    "-crf", "17",
    "-tune", "animation",
    # Audio
    "-c:a", "aac",
    "-b:a", "192k",
    # Extra
    "-movflags", "+faststart",
  ]

  defp ffmpeg_copy, do: [
     "-c:v", "copy",
     "-c:a", "copy",
     "-movflags", "+faststart",
  ]

  # These guys pretty much only use mkv to store the subtitles, their
  # videos can be fully converted to mp4 by just copying the codecs
  def ffmpeg_args(%{"subgroup" => "HorribleSubs", "ext" => "mkv"}) do
    ffmpeg_copy()
  end
  def ffmpeg_args(%{"subgroup" => "Erai-raws", "ext" => "mkv"}) do
    ffmpeg_copy()
  end

  def ffmpeg_args(%{"subgroup" => "Animu", "ext" => "mkv"}) do
    ffmpeg_copy()
  end

  # Always does fancy shit, just assume it needs full re-encode
  def ffmpeg_args(%{"subgroup" => "Judas"}),         do: ffmpeg_defaults()
  def ffmpeg_args(%{"subgroup" => "Coalgirls"}),     do: ffmpeg_defaults()
  def ffmpeg_args(%{"subgroup" => "Asenshi"}),       do: ffmpeg_defaults()
  def ffmpeg_args(%{"subgroup" => "Vivid-Asenshi"}), do: ffmpeg_defaults()
  def ffmpeg_args(%{"subgroup" => "Davinci"}),       do: ffmpeg_defaults()
  def ffmpeg_args(%{"subgroup" => "GJM"}),           do: ffmpeg_defaults()
  def ffmpeg_args(%{"subgroup" => "UTW"}),           do: ffmpeg_defaults()

  def ffmpeg_args(_), do: ffmpeg_defaults()
end

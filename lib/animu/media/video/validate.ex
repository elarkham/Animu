defmodule Animu.Media.Video.Validate do
  import Animu.FFmpeg, only: [probe: 1]

  @valid_extensions ~w(.mkv .webm .mp4)

  def validate_input(video) do
    with {:ok, video} <- check_file_exists(video),
         {:ok, video} <- check_valid_extension(video),
         {:ok, video} <- probe_input_file(video),
         {:ok, video} <- check_valid_format(video),
         {:ok, video} <- isolate_video_track(video),
         {:ok, video} <- isolate_audio_track(video),
         {:ok, video} <- set_audio_track_language(video),
         {:ok, video} <- check_for_subtitles(video),
         {:ok, video} <- check_for_fonts(video),
         do: {:ok, video}
  end

  def check_file_exists(video) do
    case File.regular?(video.input.path) do
      true ->
        {:ok, video}
      false ->
        {:error, "Video Does Not Exist"}
    end
  end

  def check_valid_extension(video) do
    case Enum.any?(@valid_extensions, &(&1 == video.input.extension)) do
      true ->
        {:ok, video}

      false ->
        {:error, "Video Has Unsupported Extension"}
    end
  end

  def probe_input_file(video) do
    case probe(video.input.path) do
      {:ok, probe_data} ->
        {:ok, %{video | input: %{video.input | probe_data: probe_data}}}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def check_valid_format(video = %{input: %{extension: ".mkv"}}) do
    input = %{video.input | format: "Matroska"}
    video = %{video | input: input}
    case video.input.probe_data["format"]["format_name"] do
      "matroska,webm" ->
        {:ok, video}
      _ ->
        {:error, "Video Extension Does Not Match It's Format"}
    end
  end

  def check_valid_format(video = %{input: %{extension: ".webm"}}) do
    input = %{video.input | format: "WebM"}
    video = %{video | input: input}
    case video.input.probe_data["format"]["format_name"] do
      "matroska,webm" ->
        {:ok, video}
      _ ->
        {:error, "Video Extension Does Not Match It's Format"}
    end
  end

  def check_valid_format(video = %{input: %{extension: ".mp4"}}) do
    input = %{video.input | format: "MPEG-4"}
    video = %{video | input: input}
    case video.input.probe_data["format"]["format_name"] do
      "mov,mp4,m4a,3gp,3g2,mj2" ->
        {:ok, video}
      _ ->
        {:error, "Video Extension Does Not Match It's Format"}
    end
  end

  def isolate_video_track(video) do
    streams = video.input.probe_data["streams"]
    search = Enum.filter(streams, &(&1["codec_type"] == "video"))
    search_count = Enum.count(search)

    cond do
      search_count == 0 ->
        {:error, "Video Does Not Contain A Video Track"}
      search_count > 1 ->
        {:error, "Video's With Multiple Video Track Are Not Supported"}
      true ->
        {:ok, %{video | video_track: List.first(search)}}
    end
  end

  def isolate_audio_track(video) do
    streams = video.input.probe_data["streams"]
    search = Enum.filter(streams, &(&1["codec_type"] == "audio"))
    search_count = Enum.count(search)

    cond do
      search_count == 0 ->
        {:error, "Video Does Not Contain An Audio Track"}
      search_count > 1 ->
        {:error, "Video's With Multiple Audio Tracks Are Not Supported"}
      true ->
        {:ok, %{video | audio_track: List.first(search)}}
    end
  end

  def set_audio_track_language(video) do
    language =
      try do
        video.audio_track["tags"]["language"]
      rescue
        _ in KeyError -> nil
      end

    audio_track = Map.put(video.audio_track, "language", language)
    video = %{video | audio_track: audio_track}

    {:ok, video}
  end

  def check_for_subtitles(video) do
    streams = video.input.probe_data["streams"]
    search = Enum.filter(streams, &(&1["codec_name"] == "ass"))
    search_count = Enum.count(search)

    cond do
      search_count == 0 ->
        {:ok, %{video | subtitles: nil}}
      search_count > 1 ->
        {:error, "Video's With Multiple Subtitle Tracks Are Not Supported"}
      true ->
        {:ok, %{video | subtitles: %{video.subtitles | data: List.first(search)}}}
    end
  end

  def check_for_fonts(video = %{subtitles: nil}), do: {:ok, video}

  def check_for_fonts(video) do
    streams = video.input.probe_data["streams"]
    search = Enum.filter(streams,
      &(&1["codec_name"] == "ttf" || &1["codec_name"] == "otf"))

    #search_count = Enum.count(search)
    #cond do
    #  search_count == 0 ->
    #    {:ok, %{video | font: nil}}
    #  true ->
    #    {:ok, %{video | font: %{video.font | data: search}}}
    #end
    {:ok, %{video | font: %{video.font | data: search}}}
  end

end

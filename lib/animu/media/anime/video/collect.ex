defmodule Animu.Media.Anime.Video.Collect do
  import Animu.Util.FFmpeg, only: [probe: 1]
  import Animu.Media.Anime.Video.Validate

  alias Animu.Media.Anime.Video.Bag

  def collect_input_data(bag) do
    with :ok <- check_file_exists(bag.input.file),
         :ok <- validate_extension(bag.input.extension),
         {:ok, bag} <- probe_input_file(bag),
         {:ok, bag} <- validate_input_format(bag),
         {:ok, bag} <- collect_video_data(bag),
         {:ok, bag} <- collect_audio_data(bag),
         {:ok, bag} <- collect_subtitle_data(bag),
         {:ok, bag} <- collect_font_data(bag),
         {:ok, bag} <- collect_font_names(bag) do
      {:ok, bag}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "unexpected error when collecting input data"}
    end
  end

  def collect_output_data(bag) do
    {:ok, bag}
  end

  defp probe_input_file(bag) do
    case probe(bag.input.file) do
      {:ok, probe_data} ->
        {:ok, Bag.put_input(bag, :probe_data, probe_data)}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def collect_video_data(%Bag{} = bag) do
    streams = bag.input.probe_data["streams"]
    search = Enum.filter(streams, &(&1["codec_type"] == "video"))
    search_count = Enum.count(search)

    cond do
      search_count == 0 ->
        {:error, "video does not contain a video track"}
      search_count > 1 ->
        {:error, "video's with multiple video track are not supported"}
      true ->
        {:ok, Map.put(bag, :video_track, List.first(search))}
    end
  end

  def collect_audio_data(%Bag{} = bag) do
    streams = bag.input.probe_data["streams"]
    search = Enum.filter(streams, &(&1["codec_type"] == "audio"))
    search_count = Enum.count(search)

    cond do
      search_count == 0 ->
        {:error, "video does not contain an audio track"}
      search_count > 1 ->
        #{:error, "Video's With Multiple Audio Tracks Are Not Supported"}
        {:ok, Map.put(bag, :audio_track, List.first(search))}
      true ->
        {:ok, Map.put(bag, :audio_track, List.first(search))}
    end
  end

  def collect_subtitle_data(%Bag{} = bag) do
    streams = bag.input.probe_data["streams"]
    search = Enum.filter(streams, &(&1["codec_name"] == "ass"))
    search_count = Enum.count(search)

    cond do
      search_count == 0 ->
        {:ok, %{bag | subtitles: nil}}
      #search_count > 1 ->
      #  {:error, "Video's With Multiple Subtitle Tracks Are Not Supported"}
      true ->
        {:ok, Bag.put_subtitles(bag, :data, List.first(search))}
    end
  end

  def collect_font_data(bag = %Bag{subtitles: nil}), do: {:ok, bag}
  def collect_font_data(%Bag{} = bag) do
    streams = bag.input.probe_data["streams"]
    search = Enum.filter(streams,
      &(&1["codec_name"] == "ttf" || &1["codec_name"] == "otf"))

    {:ok, Bag.put_font(bag, :data, search)}
  end

  #TODO Fix improper nil font detection, attempt 1
  def collect_font_names(bag = %Bag{font: nil}), do: {:ok, bag}
  def collect_font_names(bag = %Bag{font: %Bag.Font{data: nil}}), do: {:ok, bag}
  def collect_font_names(%Bag{} = bag) do
    fonts =
      try do
        bag.font.data
        |> Enum.map(&(&1["tags"]["filename"]))
      rescue
        _ in KeyError -> :error
      end

    case fonts do
      :error ->
        {:error, "failed to collect font filenames"}
      _ ->
        {:ok, Bag.put_font(bag, :filenames, fonts)}
    end
  end
end

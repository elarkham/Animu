defmodule Animu.Media.Video.Assembler do

  def assemble(video = %{subtitles: nil}), do: {:ok, aggregate(video)}

  def assemble(video) do
    with {:ok, video} <- collect_font_names(video),
         subtitles    <- assemble_subtitles(video),
         video        <- aggregate(video, subtitles),
         do: {:ok, video}
  end

  def aggregate(video, subtitles \\ nil) do
    format_data = video.output.probe_data["format"]
    output =
      %{ "filename" => video.output.filename,
         "dir" => video.output.dir,
         "extension" => video.output.extension,
         "format" => video.output.format,
       }

    Map.merge(format_data, output)
      |> Map.put("video_track", video.video_track)
      |> Map.put("audio_track", video.audio_track)
      |> Map.put("subtitles", subtitles)
  end

  def collect_font_names(video) do
    fonts =
      try do
        video.font.data
        |> Enum.map(&(&1["tags"]["filename"]))
      rescue
        _ in KeyError -> :error
      end

    case fonts do
      :error ->
        {:error, "Failed To Collect Font Filenames"}
      fonts ->
        {:ok, %{video | font: %{video.font | filenames: fonts}}}
    end
  end

  def assemble_subtitles(video) do
    %{ "type" => "ass",
       "dir" => video.subtitles.dir,
       "filename" => video.subtitles.filename,
       "fonts" => video.font.filenames,
       "font_dir" => video.font.dir,
     }
  end

end

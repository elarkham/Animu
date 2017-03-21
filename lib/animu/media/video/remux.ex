defmodule Animu.Media.Video.Remux do
  alias Animu.Media.FFmpeg

  @output_dir "videos"
  @subtitles_dir "subtitles"
  @font_dir "fonts"

  def remux(video = %{input: %{format: "WebM"}}) do
    with {:ok, video} <- generate_directories(video),
         {:ok, video} <- copy_original(video),
         {:ok, video} <- probe_output_file(video),
         do: {:ok, video}
  end

  def remux(video = %{input: %{format: "MPEG-4"}}) do
    with {:ok, video} <- generate_directories(video),
         {:ok, video} <- copy_original(video),
         {:ok, video} <- probe_output_file(video),
         do: {:ok, video}
  end

  def remux(video = %{input: %{format: "Matroska"}, subtitles: nil}) do
    with {:ok, video} <- generate_directories(video),
         {:ok, video} <- convert_mkv_to_mp4(video),
         {:ok, video} <- probe_output_file(video),
         do: {:ok, video}
  end

  def remux(video = %{input: %{format: "Matroska"}}) do
    with {:ok, video} <- generate_directories(video),
         {:ok, video} <- convert_mkv_to_mp4(video),
         {:ok, video} <- extract_subtitles(video),
         {:ok, video} <- extract_fonts(video),
         {:ok, video} <- probe_output_file(video),
         do: {:ok, video}
  end

  def generate_directories(video = %{subtitles: nil}) do
    video =
      %{video | output: %{video.output | dir: @output_dir}}

    case File.mkdir_p(video.output.dir) do
      :ok ->
        {:ok, video}
      {:error, _} ->
        {:error, "Failed To Create Output Directory"}
    end
  end

  def generate_directories(video) do
    video =
      %{ video |
         output: %{video.output | dir: @output_dir},
         subtitles: %{video.subtitles | dir: @subtitles_dir},
         font: %{video.font | dir: @font_dir},
       }

    with :ok <- File.mkdir_p(video.output.dir),
         :ok <- File.mkdir_p(video.subtitles.dir),
         :ok <- File.mkdir_p(video.font.dir) do
      {:ok, video}
    else
      _ -> {:error, "Failed To Create Output Directories"}
    end
  end

  def copy_original(video) do
    output =
      %{ video.output |
         filename: video.input.filename,
         extension: video.input.extension,
         dir: video.input.dir,
         path: Path.join(video.input.dir, video.input.filename)
       }

    case File.cp(video.input.path, output.path, true) do
    	:ok ->
				{:ok, %{video | output: video.input}}
			{:error, _} ->
				{:error, "Failed To Copy Video File"}
		end
  end

  def probe_output_file(video) do
    case FFmpeg.probe(video.output.path) do
      {:error, reason} ->
        {:error, reason}
      {:ok, probe_data} ->
        {:ok, %{video | output: %{video.output | probe_data: probe_data}}}
    end
  end

  def convert_mkv_to_mp4(video = %{input: %{format: "Matroska"}}) do
    extension = ".mp4"
    filename = video.name <> extension
    path = Path.join(video.output.dir, filename)
    format = "MPEG-4"

    output =
      %{ video.output |
         filename: filename,
         extension: extension,
         path: path,
         format: format,
       }

    video  = %{video | output: output}

    case FFmpeg.mkv_to_mp4(video.input.path, video.output.path) do
      {_, 0} ->
        {:ok, video}
      {_, _} ->
        {:error, "Failed To Convert MKV->MP4"}
    end
  end

  def extract_subtitles(video = %{input: %{format: "Matroska"}}) do
    filename = video.name <> ".ass"
    path = Path.join(video.subtitles.dir, filename)

    subtitles = %{video.subtitles | filename: filename}
    video  = %{video | subtitles: subtitles}

    case FFmpeg.extract_subtitles(video.input.path, path) do
      {_, 0} ->
        {:ok, video}
      {_, _} ->
        {:error, "Failed to Extract Subtitles"}
    end
  end

  def extract_fonts(video = %{input: %{format: "Matroska"}}) do
     case FFmpeg.extract_fonts(video.input.path, video.font.dir) do
      {_, num} when num > 1 ->
        {:error, "Failed To Extract Fonts"}
      {_, _} ->
        {:ok, video}
     end
  end
end

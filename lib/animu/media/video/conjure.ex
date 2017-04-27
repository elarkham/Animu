defmodule Animu.Media.Video.Conjure do
  alias Animu.Media.FFmpeg
  alias Animu.Media.Video.Bag

  @output_dir "videos"
  @subtitles_dir "subtitles"
  @font_dir "fonts"

  def conjure_output(bag = %Bag{input: %Bag.IO{format: "WebM"}}) do
    with {:ok, bag} <- conjure_directories(bag),
         {:ok, bag} <- copy_input(bag),
         {:ok, bag} <- probe_output_file(bag) do
      {:ok, bag}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unexpected Error When Conjuring Output"}
    end
  end

  def conjure_output(bag = %Bag{input: %Bag.IO{format: "MPEG-4"}}) do
    with {:ok, bag} <- conjure_directories(bag),
         {:ok, bag} <- copy_input(bag),
         {:ok, bag} <- probe_output_file(bag) do
      {:ok, bag}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unexpected Error When Conjuring Output"}
    end
  end

  def conjure_output(bag = %Bag{input: %Bag.IO{format: "Matroska"}, subtitles: nil}) do
    with {:ok, bag} <- conjure_directories(bag),
         {:ok, bag} <- convert_mkv_to_mp4(bag),
         {:ok, bag} <- probe_output_file(bag) do
      {:ok, bag}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unexpected Error When Conjuring Output"}
    end
  end

  def conjure_output(bag = %Bag{input: %Bag.IO{format: "Matroska"}}) do
    with {:ok, bag} <- conjure_directories(bag),
         {:ok, bag} <- convert_mkv_to_mp4(bag),
         {:ok, bag} <- extract_subtitles(bag),
         {:ok, bag} <- extract_fonts(bag),
         {:ok, bag} <- probe_output_file(bag) do
      {:ok, bag}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unexpected Error When Conjuring Output"}
    end
  end

  def conjure_directories(bag = %Bag{subtitles: nil}) do
    bag = Bag.put_output(bag, :dir, @output_dir)
    output_dir = Path.join(bag.output_root, bag.output.dir)

    case File.mkdir_p(output_dir) do
      :ok ->
        {:ok, bag}
      {:error, _} ->
        {:error, "Failed To Create Output Directory"}
    end
  end

  def conjure_directories(bag = %Bag{}) do
    bag =
      bag
      |> Bag.put_output(:dir, @output_dir)
      |> Bag.put_subtitles(:dir, @subtitles_dir)
      |> Bag.put_font(:dir, @font_dir)

    output_dir    = Path.join(bag.output_root, bag.output.dir)
    subtitles_dir = Path.join(bag.output_root, bag.subtitles.dir)
    font_dir      = Path.join(bag.output_root, bag.font.dir)

    with :ok <- File.mkdir_p(output_dir),
         :ok <- File.mkdir_p(subtitles_dir),
         :ok <- File.mkdir_p(font_dir) do
      {:ok, bag}
    else
      _ -> {:error, "Failed To Create Output Directories"}
    end
  end

  def copy_input(bag = %Bag{}) do
    extension = bag.input.extension
    filename = bag.input.filename
    dir = @output_dir
    file = Path.join([bag.output_root, dir, bag.input.filename])
    format = bag.input.format

    output =
      %Bag.IO{
         bag.output |
         filename: filename,
         extension: extension,
         dir: dir,
         file: file,
         format: format,
       }

    case File.cp(bag.input.file, output.file, true) do
    	:ok ->
				{:ok, %{bag | output: output}}
			{:error, _} ->
				{:error, "Failed To Copy Video File"}
		end
  end

  def probe_output_file(bag = %Bag{}) do
    case FFmpeg.probe(bag.output.file) do
      {:error, reason} ->
        {:error, reason}
      {:ok, probe_data} ->
        {:ok, Bag.put_output(bag, :probe_data, probe_data)}
    end
  end

  def convert_mkv_to_mp4(bag = %Bag{input: %Bag.IO{format: "Matroska"}}) do
    extension = ".mp4"
    filename = bag.name <> extension
    dir = @output_dir
    file = Path.join([bag.output_root, dir, filename])
    format = "MPEG-4"

    output =
      %Bag.IO{
         bag.output |
         filename: filename,
         extension: extension,
         dir: dir,
         file: file,
         format: format,
       }

    case FFmpeg.mkv_to_mp4(bag.input.file, output.file) do
      {_, 0} ->
        {:ok, Map.put(bag, :output, output)}
      {_, _} ->
        {:error, "Failed To Convert MKV->MP4"}
    end
  end

  def extract_subtitles(bag = %Bag{input: %Bag.IO{format: "Matroska"}}) do
    filename = bag.name <> ".ass"
    file = Path.join([bag.output_root, bag.subtitles.dir, filename])

    case FFmpeg.extract_subtitles(bag.input.file, file) do
      {_, 0} ->
        {:ok, Bag.put_subtitles(bag, :filename, filename)}
      {_, _} ->
        {:error, "Failed to Extract Subtitles"}
    end
  end

  def extract_fonts(bag = %Bag{input: %Bag.IO{format: "Matroska"}}) do
    font_dir = Path.join(bag.output_root, bag.font.dir)

    case FFmpeg.extract_fonts(bag.input.file, font_dir) do
     {_, num} when num > 1 ->
       {:error, "Failed To Extract Fonts"}
     {_, _} ->
       {:ok, bag}
    end
  end
end
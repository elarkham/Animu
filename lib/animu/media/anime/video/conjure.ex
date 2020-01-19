defmodule Animu.Media.Anime.Video.Conjure do
  alias Animu.Util.FFmpeg
  alias Animu.Util.ImageMagick, as: Image
  alias Animu.Media.Anime.Video.Bag
  require Bag

  @output_dir "videos"
  @subtitles_dir "subtitles"
  @font_dir "fonts"
  @thumb_dir "thumbs"

  def conjure_output(_golem, bag = %Bag{input: %Bag.IO{format: "WebM"}}) do
    with {:ok, bag} <- conjure_directories(bag),
         {:ok, bag} <- copy_input(bag),
         {:ok, bag} <- probe_output_file(bag) do
      {:ok, bag}
    else
      {:error, reason} -> {:error, reason}
      error ->
        {:error, "unexpected error when conjuring output: #{inspect(error)}"}
    end
  end

  def conjure_output(_golem, bag = %Bag{input: %Bag.IO{format: "MPEG-4"}}) do
    with {:ok, bag} <- conjure_directories(bag),
         {:ok, bag} <- copy_input(bag),
         {:ok, bag} <- probe_output_file(bag) do
      {:ok, bag}
    else
      {:error, reason} -> {:error, reason}
      error ->
        {:error, "unexpected error when conjuring output: #{inspect(error)}"}
    end
  end

  def conjure_output(golem, bag = %Bag{input: %Bag.IO{format: "Matroska"}, subtitles: nil}) do
    with {:ok, bag} <- conjure_directories(bag),
         {:ok, bag} <- convert_mkv_to_mp4(golem, bag),
         {:ok, bag} <- probe_output_file(bag) do
      {:ok, bag}
    else
      {:error, reason} -> {:error, reason}
      error ->
        {:error, "unexpected error when conjuring output: #{inspect(error)}"}
    end
  end

  def conjure_output(golem, bag = %Bag{input: %Bag.IO{format: "Matroska"}}) do
    with {:ok, bag} <- conjure_directories(bag),
         {:ok, bag} <- convert_mkv_to_mp4(golem, bag),
         {:ok, bag} <- extract_subtitles(bag),
         {:ok, bag} <- extract_fonts(bag),
         {:ok, bag} <- probe_output_file(bag) do
      {:ok, bag}
    else
      {:error, reason} -> {:error, reason}
      error ->
        {:error, "unexpected error when conjuring output: #{inspect(error)}"}
    end
  end

  def conjure_directories(bag = %Bag{subtitles: nil}) do
    bag = Bag.put_output(bag, :dir, @output_dir)
    output_dir = Path.join(bag.output_root, bag.output.dir)

    case File.mkdir_p(output_dir) do
      :ok ->
        {:ok, bag}
      {:error, _} ->
        {:error, "failed to create output directory"}
    end
  end

  def conjure_directories(bag = %Bag{}) do
    bag =
      bag
      |> Bag.put_output(:dir, @output_dir)
      |> Bag.put_subtitles(:dir, @subtitles_dir)
      |> Bag.put_font(:dir, @font_dir)
      |> Bag.put_thumb(:dir, Path.join(@thumb_dir, bag.name))

    output_dir    = Path.join(bag.output_root, bag.output.dir)
    subtitles_dir = Path.join(bag.output_root, bag.subtitles.dir)
    font_dir      = Path.join(bag.output_root, bag.font.dir)
    thumb_dir     = Path.join(bag.output_root, bag.thumb.dir)

    with :ok <- File.mkdir_p(output_dir),
         :ok <- File.mkdir_p(subtitles_dir),
         :ok <- File.mkdir_p(font_dir),
         :ok <- File.mkdir_p(thumb_dir) do
      {:ok, bag}
    else
      _ -> {:error, "failed to create output directories"}
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
				{:ok, %Bag{bag | output: output}}
			{:error, _} ->
				{:error, "failed to copy video file"}
		end
  end

  def probe_output_file(bag = %Bag{}) do
    case FFmpeg.probe(bag.output.file) do
      {:ok, probe_data} ->
        {:ok, Bag.put_output(bag, :probe_data, probe_data)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def convert_mkv_to_mp4(golem, bag = %Bag{input: %Bag.IO{format: "Matroska"}}) do
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

    case FFmpeg.mkv_to_mp4(golem, bag.input.file, output.file) do
      :ok ->
        {:ok, %Bag{bag | output: output}}

      {:error, status} ->
        {:error, "failed to convert mkv->mp4 - status: #{inspect status}"}
    end
  end

  def extract_subtitles(bag = %Bag{input: %Bag.IO{format: "Matroska"}}) do
    filename = bag.name <> ".ass"
    file = Path.join([bag.output_root, bag.subtitles.dir, filename])

    case FFmpeg.extract_subtitles(bag.input.file, file) do
      {_, 0} ->
        {:ok, Bag.put_subtitles(bag, :filename, filename)}
      {_, _} ->
        {:error, "failed to extract subtitles"}
    end
  end

  def extract_fonts(bag = %Bag{input: %Bag.IO{format: "Matroska"}}) do
    font_dir = Path.join(bag.output_root, bag.font.dir)

    case FFmpeg.extract_fonts(bag.input.file, font_dir) do
     {_, num} when num > 1 ->
       {:error, "failed to extract fonts"}
     {_, _} ->
       {:ok, bag}
    end
  end

  def conjure_thumbnails(bag) do
    {duration, _} =
      bag.output.probe_data["format"]["duration"]
      |> Integer.parse()

    dir = bag.thumb.dir
    dir_path = Path.join(bag.output_root, dir)

    image = Path.join(bag.thumb.dir, "original.jpg")
    image_path = Path.join(bag.output_root, image)

    video = bag.output.file

    sizes =
      %{ "medium" => {400, 225} }

    with        {_, 0} <- FFmpeg.random_thumbnail(video, duration, image_path),
         {:ok, thumbs} <- Image.gen_thumbnails(image_path, dir_path, sizes),
                thumbs <- prefix_thumbs(thumbs, dir),
                thumbs <- Map.put(thumbs, "original", image) do

      {:ok, Bag.put_thumb(bag, :data, thumbs)}
    else
      _ -> {:error, "failed to conjure thumbnails"}
    end
  end

  defp prefix_thumbs(thumbs, dir) do
    Map.new(thumbs, fn {name, file} ->
      {name, Path.join(dir, file)}
    end)
  end

 end

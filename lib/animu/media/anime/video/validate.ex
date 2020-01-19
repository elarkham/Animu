defmodule Animu.Media.Anime.Video.Validate do
  alias Animu.Media.Anime.Video.Bag

  @valid_extensions ~w(.mkv .webm .mp4)

  def check_file_exists(file) do
    case File.regular?(file) do
      true -> :ok
      false -> {:error, "video does not exist: #{inspect file}"}
    end
  end

  def validate_extension(extension) do
    case Enum.any?(@valid_extensions, &(&1 == extension)) do
      true -> :ok
      false -> {:error, "video has unsupported extension"}
    end
  end

  def validate_input_format(bag = %Bag{input: %Bag.IO{extension: ".mkv"}}) do
    bag = Bag.put_input(bag, :format, "Matroska")
    case bag.input.probe_data["format"]["format_name"] do
      "matroska,webm" ->
        {:ok, bag}
      _ ->
        {:error, "video extension does not match it's format"}
    end
  end

  def validate_input_format(bag = %Bag{input: %Bag.IO{extension: ".webm"}}) do
    bag = Bag.put_input(bag, :format, "WebM")
    case bag.input.probe_data["format"]["format_name"] do
      "matroska,webm" ->
        {:ok, bag}
      _ ->
        {:error, "video extension does not match it's format"}
    end
  end

  def validate_input_format(bag = %Bag{input: %Bag.IO{extension: ".mp4"}}) do
    bag = Bag.put_input(bag, :format, "MPEG-4")
    case bag.input.probe_data["format"]["format_name"] do
      "mov,mp4,m4a,3gp,3g2,mj2" ->
        {:ok, bag }
      _ ->
        {:error, "video extension does not match it's format"}
    end
  end
end

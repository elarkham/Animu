defmodule Animu.Util.ImageMagick do

  @exec  "convert"

  def identify(input) do
    args =
      [ input,
        "json:"
      ]

    with {json_output,  0} <- System.cmd(@exec, args),
         {:ok, identity} <- Poison.Parser.parse(json_output) do
      {:ok, identity}
    else
      {:error, _} -> {:error, "Failed to parse ImageMagick json"}
      _           -> {:error, "ImageMagick identification Failed"}
    end
  end

  def identify!(input) do
    {:ok, identity} = identify(input)
    identity
  end

  def resize(input, output, {width, height}) do
    args =
      [ input,
        "-resize", "#{width}x#{height}^",
        "-gravity", "center",
        "-crop", "#{width}x#{height}+0+0",
        "+repage",
        output
      ]

    System.cmd @exec, args
  end

  def convert(input, output) do
    args = [input, output]
    System.cmd @exec, args
  end

  def gen_thumbnails(image, dir, sizes) do
    Enum.reduce_while(sizes, {:ok, %{}}, fn {name, size}, {:ok, acc} ->
      thumb  = name <> ".jpg"
      output = Path.join(dir, thumb)
      case resize(image, output, size) do
        {_, 0} ->
          {:cont, {:ok, Map.put(acc, name, thumb)}}
        _ ->
          {:halt, {:error, "Resize of '#{image}' to '#{output}' Failed"}}
      end
    end)
  end

  def write_image(data, path) do
    case File.write(path, data) do
      {:error, _} ->
        {:error, "Failed to Write Image: '#{path}'"}

      :ok -> :ok
    end
  end

end

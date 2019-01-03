defmodule Animu.Media.ImageMagick do

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

end

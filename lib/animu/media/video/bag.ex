defmodule Animu.Media.Video.Bag do
  alias __MODULE__, as: Bag
  #alias Animu.Media.Video

  defstruct [
    :name,
    :output_root,
    :input_root,
    :video_track,
    :audio_track,
    :input,
    :output,
    :subtitles,
    :font,
  ]

  defmodule IO do
    defstruct [
      :file,
      :dir,
      :filename,
      :extension,
      :format,
      :probe_data,
    ]
  end

  defmodule Subtitles do
    defstruct [
      :data,
      :dir,
      :filename,
    ]
  end

  defmodule Font do
    defstruct [
      :data,
      :dir,
      :filenames,
    ]
  end

  def new(input_path, series_dir) do
    dir = Path.dirname(input_path)
    filename = Path.basename(input_path)
    extension = Path.extname(input_path)
    name = Path.rootname(filename)

    input_root =
      Path.join(Application.get_env(:animu, :input_root), series_dir)
    output_root =
      Path.join(Application.get_env(:animu, :output_root), series_dir)

    file = Path.join([input_root, input_path])

    %Bag{
      name: name,

      input_root: input_root,
      output_root: output_root,

      video_track: nil,
      audio_track: nil,

      input: %IO{
        file: file,
        dir: dir,
        filename: filename,
        extension: extension,
        format: nil,
        probe_data: nil,
      },
      output: %IO{},

      subtitles: %Subtitles{},
      font: %Font{},
    }
  end

  def put_input(%Bag{} = bag, key, value) when is_atom(key) do
    input = Map.put(bag.input, key, value)
    Map.put(bag, :input, input)
  end

  def put_output(%Bag{} = bag, key, value) when is_atom(key) do
    output = Map.put(bag.output, key, value)
    Map.put(bag, :output, output)
  end

  def put_subtitles(%Bag{} = bag, key, value) when is_atom(key) do
    subtitles = Map.put(bag.subtitles, key, value)
    Map.put(bag, :subtitles, subtitles)
  end

  def put_font(%Bag{} = bag, key, value) when is_atom(key) do
    font = Map.put(bag.font, key, value)
    Map.put(bag, :font, font)
  end
end
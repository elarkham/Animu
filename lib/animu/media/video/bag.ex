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
    :thumb,
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

  defmodule Thumb do
    defstruct [
      :data,
      :dir,
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
      thumb: %Thumb{},
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

  def put_thumb(%Bag{} = bag, key, value) when is_atom(key) do
    thumb = Map.put(bag.thumb, key, value)
    Map.put(bag, :thumb, thumb)
  end

  #pipe :put_font, [:input,:format], "MKV" do
  #def put_font(match [:input,:format], "MKV") do
  #def put_font(bag = get Bag, [:input,:format], "MKV") do
  #def put_font(bag = %Bag{input: %Bag.IO{format: "MKV"}}) do
  def put_font(%Bag{} = bag, key, value) when is_atom(key) do
    font = Map.put(bag.font, key, value)
    Map.put(bag, :font, font)
  end

  defmacro match(keys, value) do
    build = build_get(Bag, keys, value)
    quote do
      var!(bag) = unquote(build)
    end
  end

  defmacro get(module, keys, value) do
    build_get(module, keys, value)
  end

  defp build_get(nil, [], value) do
    value
  end
  defp build_get(module, [k | keys], value) do
    type =
      %{input: Bag.IO,
        output: Bag.IO,
        subtitles: Bag.Subtitles,
        font: Bag.Font,
       }

    next = build_get(type[k], keys, value)
    {:%, [],
     [{:__aliases__, [alias: false], [module]},
      {:%{}, [], [{k, next}]}]}
  end

end

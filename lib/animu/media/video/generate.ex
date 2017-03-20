defmodule Animu.Media.Video.Generate do

  import Animu.Media.Video.Validate
  import Animu.Media.Video.Remux
  import Animu.Media.Video.Assembler

  alias Animu.Media
  alias Animu.Media.Video
  alias Ecto.Changeset

  def generate_video(changeset =
		%Changeset{
			valid?: true,
			params: %{
        "video_path" => input_path
      },
    }) do

    series_id = changeset.changes.series_id
    series = Media.get_series!(series_id)

    case generate(input_path, series.directory) do
      {:ok, video} ->
        Changeset.put_embed(changeset, :video, video, with: &Video.changeset/2)
      {:error, reason} ->
        Changeset.add_error(changeset, :video, reason)
    end
  end
  def generate_video(changeset), do: changeset

  def generate_video(changeset =
		%Changeset{
			valid?: true,
			params: %{
        "video_path" => input_path
      },
    }, series_dir) do

    case generate(input_path, series_dir) do
      {:ok, video} ->
        Changeset.put_embed(changeset, :video, video, with: &Video.changeset/2)
      {:error, reason} ->
        Changeset.add_error(changeset, :video, reason)
    end
  end
  def generate_video(changeset, _), do: changeset

  def generate(input_path, series_dir) do
    with :ok   <- cd_series_dir(series_dir),
         video <- generate_map(input_path, series_dir),
         {:ok, video} <- validate_input(video),
         {:ok, video} <- remux(video),
         {:ok, video} <- assemble(video),
         do: {:ok, video}
  end

  defp cd_series_dir(series_dir) do
    output_root = Application.get_env(:animu, :output_root)
    working_dir = Path.join(output_root, series_dir)

    with  :ok <- File.mkdir_p(working_dir),
          :ok <- File.cd(working_dir) do
      :ok
    else
      {:error, _} -> {:error, "Failed To Set CWD to Series Dir"}
    end
  end

  defp generate_map(input_path, series_dir) do
    dir = Path.dirname(input_path)
    filename = Path.basename(input_path)
    extension = Path.extname(input_path)
    name = Path.rootname(filename)

    input_root = Application.get_env(:animu, :input_root)
    input_path = Path.join([input_root, series_dir, input_path])

    input =
      %{ path: input_path,
         dir: dir,
         filename: filename,
         extension: extension,
         format: nil,
         probe_data: nil,
       }

    output =
      %{ path: nil,
         dir: nil,
         filename: nil,
         extension: nil,
         format: nil,
         probe_data: nil,
       }

    subtitles =
      %{ data: nil,
         dir: nil,
         filename: nil,
       }

    font =
      %{ data: nil,
         dir: nil,
         filenames: nil,
       }

    %{ name: name,
       video_track: nil,
       audio_track: nil,
       input: input,
       output: output,
       subtitles: subtitles,
       font: font,
     }
  end
end

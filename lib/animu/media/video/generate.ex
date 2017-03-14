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
			params: %{"video_path" => input_path}}) do

    series_id = changeset.changes.series_id
    series = Media.get_series!(series_id)

    case generate(input_path, series.directory) do
      {:ok, video} ->
        Changeset.put_embed(changeset, video, with: &Video.changeset/2)
      {:error, reason} ->
        Changeset.add_error(changeset, :video, reason)
    end
  end

  def generate(input_path, series_dir) do
    with :ok   <- cd_series_dir(series_dir),
         video <- generate_map(input_path),
         {:ok, video} <- validate_input(video),
         {:ok, video} <- remux(video),
         {:ok, video} <- assemble(video),
         do: {:ok, video}
  end

  defp cd_series_dir(series_dir) do
    root_path = Application.get_env(:animu, :file_root)
    working_dir = Path.join(root_path, series_dir)

    case File.cd(working_dir) do
      {:error, _} -> {:error, "Failed To Set CWD to Series Dir"}
      :ok         -> :ok
    end
  end

  defp generate_map(input_path) do
    input_output =
      %{ path: input_path,
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

    %{ name: nil,
       video_track: nil,
       audio_track: nil,
       input: input_output,
       output: input_output,
       subtitles: subtitles,
       font: font,
     }
  end
end

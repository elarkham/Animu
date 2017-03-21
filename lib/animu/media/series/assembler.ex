defmodule Animu.Media.Series.Assembler do

  import Animu.Media.Video.Generate
  import Ecto.Changeset

  alias Animu.Media.Episode
  alias Animu.Schema

  def assemble(series) do
    Map.put(series.kitsu_data, :episodes, series.episodes)
      |> Map.put(:poster_image, series.poster_image)
      |> Map.put(:cover_image, series.cover_image)
      |> convert_to_string_map
  end

  defp convert_to_string_map(map) do
    for {key, val} <- map, into: %{}, do: {to_string(key), val}
  end

  def assemble_episodes(episodes, series_dir) do
    episodes =
    Task.async_stream(episodes, fn ep ->
      episode_changeset(ep, series_dir)
    end, timeout: 1000 * 60 * 60)
    |> Enum.to_list()
    |> Enum.map(fn {:ok, ep} -> ep end)
    IO.inspect episodes
    episodes
  end

  defp episode_changeset(attrs, series_dir) do
    %Episode{}
    |> cast(attrs, Schema.all_fields(Episode, except: [:video]) ++ [:video_path])
    |> validate_required([:title, :number])
    |> generate_video(series_dir)
  end
end

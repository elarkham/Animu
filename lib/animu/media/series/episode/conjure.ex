defmodule Animu.Media.Series.Episode.Conjure do
  alias Animu.Media.Series.Episode

  def spawn_episode(number, video_path \\ nil) do
    title_num = format_number(number)
    %Episode{
      title: "Episode #{title_num}",
      number: number/1,
      video_path: video_path,
    }
  end

  defp format_number(int) when is_integer(int), do: int
  defp format_number(float) when is_float(float) do
    case Float.ratio(float) do
      {int, 1} -> int
      _        -> float
    end
  end
end

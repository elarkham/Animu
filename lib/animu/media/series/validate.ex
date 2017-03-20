defmodule Animu.Media.Series.Validate do

  def validate_input(series) do
    with {:ok, series} <- check_kitsu_id(series),
         {:ok, series} <- check_series_dir(series),
         {:ok, series} <- check_regex(series),
         do: {:ok, series}
  end

  defp check_kitsu_id(series) do
    case series do
      %{kitsu_id: nil} ->
        {:error, "Kitsu Id Is Required For Population"}
      %{kitsu_id: _} ->
        {:ok, series}
    end
  end

  defp check_series_dir(series) do
    case series do
      %{dir: nil} ->
        {:error, "Series Directory Is Required For Population"}
      %{dir: _} ->
        {:ok, series}
    end
  end

  defp check_regex(series = %{gen_exist_ep: true}) do
    case series do
      %{regex: nil} ->
        {:error, "Regex Is Required To Add Existing Episodes"}
      %{regex: _} ->
        {:ok, series}
    end
  end
  defp check_regex(series), do: {:ok, series}
end

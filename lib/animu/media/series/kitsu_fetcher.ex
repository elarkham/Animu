defmodule Animu.Media.Series.KitsuFetcher do
  import Animu.Media.Kitsu

  alias HTTPoison.Response

  def get_kitsu_data(series) do
    with {:ok, series} <- request_kitsu_data(series),
         {:ok, series} <- get_poster_data(series),
         {:ok, series} <- get_cover_data(series),
         do: {:ok, series}
  end

  #def get_kitsu_episode_data(series) do
  #  case request_related("anime", "episodes", series.kitsu_id) do
  #    {:ok, episodes} ->
  #      {:ok, Enum.map(episodes, &format_to_episode/1)}
  #    {:error, reason} ->
  #      {:error, reason}
  #  end
  #end

  def get_kitsu_episode_data(series) do
    case request_relationship("anime", "episodes", series.kitsu_id) do
      {:ok, episodes} ->
        {:ok, Enum.map(episodes, &format_to_episode/1)}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp request_kitsu_data(series) do
    case request("anime", series.kitsu_id) do
      {:ok, kitsu_data} ->
        {:ok, %{series | kitsu_data: format_to_series(kitsu_data)}}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_poster_data(series) do
    poster_data = Map.new(series.kitsu_data.poster_urls, &fetch_url/1)
    case Map.to_list(poster_data) do
      [{:error, reason} | _] -> {:error, reason}
      _ -> {:ok, %{series | poster_image: poster_data}}
    end
  end

  defp get_cover_data(series) do
    cover_data = Map.new(series.kitsu_data.cover_urls, &fetch_url/1)
    case Map.to_list(cover_data) do
      [{:error, reason} | _] -> {:error, reason}
      _ -> {:ok, %{series | cover_image: cover_data}}
    end
  end

	defp fetch_url({key, url}) do
    case HTTPoison.get(url) do
   	  {:ok, %Response{body: image_data}} ->
        {key, image_data}
      _ ->
        {:error, "Failed To Download Image"}
    end
	end

end

defmodule Animu.Media.Series.Collect do
  import Animu.Media.Kitsu

  alias HTTPoison.Response
  alias Animu.Media.Series.Bag

  def collect_kitsu_data(%Bag{} = bag) do
    with {:ok, bag} <- request_kitsu_data(bag),
         {:ok, bag} <- request_kitsu_episode_data(bag),
         {:ok, bag} <- download_poster_data(bag),
         {:ok, bag} <- download_cover_data(bag),
         do: {:ok, bag}
  end

  defp request_kitsu_data(%Bag{} = bag) do
    case request("anime", bag.kitsu_id) do
      {:ok, kitsu_data} ->
        kitsu_data = format_to_series(kitsu_data)
        {:ok, Bag.apply_kitsu_data(bag, kitsu_data)}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp request_kitsu_episode_data(%Bag{} = bag) do
    case request_relationship("anime", "episodes", bag.kitsu_id) do
      {:ok, episodes} ->
        episodes = Enum.map(episodes, &format_to_episode/1)
        {:ok, Map.put(bag, :episodes, episodes)}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp download_poster_data(%Bag{} = bag) do
    poster_data =
      Enum.reduce_while(bag.kitsu_data.poster_urls, %{}, &fetch_url/2)
    case poster_data do
      {:error, reason} -> {:error, reason}
      poster_data -> {:ok, Map.put(bag, :poster_image, poster_data)}
    end
  end

  defp download_cover_data(%Bag{} = bag) do
    cover_data =
      Enum.reduce_while(bag.kitsu_data.cover_urls, %{}, &fetch_url/2)
    case cover_data do
      {:error, reason} -> {:error, reason}
      cover_data -> {:ok, Map.put(bag, :cover_image, cover_data)}
    end
  end

	defp fetch_url({key, url}, acc) do
    case HTTPoison.get(url) do
   	  {:ok, %Response{body: image_data}} ->
        {:cont, Map.put(acc, key, image_data)}
      _ ->
        {:halt, {:error,
          "Failed To Download Image: '#{key}', from URL: '#{url}'"}}
    end
	end

end

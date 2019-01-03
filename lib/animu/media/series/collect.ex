defmodule Animu.Media.Series.Collect do
  import Animu.Media.Kitsu

  alias HTTPoison.Response
  alias Animu.Media.Series.Bag
  alias Animu.Media.Upload.Image

  ## Collect Kitsu Data
  def collect_kitsu_data(%Bag{} = bag) do
    with {:ok, bag} <- request_kitsu_data(bag),
         {:ok, bag} <- request_kitsu_episode_data(bag),
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
        {:ok, Map.put(bag, :kitsu_eps, episodes)}
      {:error, reason} ->
        {:error, reason}
    end
  end

end

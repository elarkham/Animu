defmodule Animu.Media.Franchise.Collect do

  alias HTTPoison.Response
  alias Animu.Media.Franchise.Bag

  def download_poster_data(%Bag{poster_url: nil} = bag), do: {:ok, bag}
  def download_poster_data(%Bag{} = bag) do
    poster_data =
      Enum.reduce_while(bag.poster_url, %{}, &fetch_url/2)
    case poster_data do
      {:error, reason} -> {:error, reason}
      poster_data -> {:ok, Map.put(bag, :poster_image, poster_data)}
    end
  end

  def download_cover_data(%Bag{cover_url: nil} = bag), do: {:ok, bag}
  def download_cover_data(%Bag{} = bag) do
    cover_data =
      Enum.reduce_while(bag.cover_url, %{}, &fetch_url/2)
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

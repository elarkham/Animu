defmodule Animu.Media.Franchise.Conjure do
  alias Animu.Media.Franchise.Bag

  def conjure_images(%Bag{} = bag) do
    with :ok <- File.mkdir_p(bag.output_dir),
         :ok <- File.cd(bag.output_dir),
         :ok <- File.mkdir_p(bag.poster_dir),
         :ok <- File.mkdir_p(bag.cover_dir),
         {:ok, bag} <- conjure_poster_images(bag),
         {:ok, bag} <- conjure_cover_images(bag),
         :ok <- File.cd(Application.app_dir(:animu)) do
      {:ok, bag}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unexpected Error When Conjuring Franchise Images"}
    end
  end

  defp conjure_poster_images(%Bag{poster_image: nil} = bag), do: {:ok, bag}
  defp conjure_poster_images(%Bag{} = bag) do
    poster_image =
      Enum.reduce_while(bag.poster_image, %{}, fn kv, acc ->
        write_image(kv, acc, bag.poster_dir)
      end)

    case poster_image do
      {:error, reason} -> {:error, reason}
      poster_image -> {:ok, Map.put(bag, :poster_image, poster_image)}
    end
  end

  defp conjure_cover_images(%Bag{cover_image: nil} = bag), do: {:ok, bag}
  defp conjure_cover_images(%Bag{} = bag) do
    cover_image =
      Enum.reduce_while(bag.cover_image, %{}, fn kv, acc ->
        write_image(kv, acc, bag.cover_dir)
      end)

    case cover_image do
      {:error, reason} -> {:error, reason}
      cover_image -> {:ok, Map.put(bag, :cover_image, cover_image)}
    end
  end

  defp write_image({key, data}, acc, dir) do
    filename = key <> ".jpg"
    path = Path.join(dir, filename)
    case File.write(path, data) do
      :ok ->
        {:cont, Map.put(acc, key, path)}
      {:error, _} ->
        {:halt, {:error, "Failed To Write Image: #{filename}"}}
    end
  end

end

defmodule Animu.Media.Series.Conjure do
  import Animu.Media.Episode.Conjure, only: [spawn_episode: 1, spawn_episode: 2]
  alias Animu.Media.Series.Bag
  alias Animu.Media.ImageMagick

  ## Episode Handling

  def spawn_episodes(:kitsu, bag) do
    episodes =
      merge_episode_lists(bag.kitsu_eps, bag.episodes)

    {:ok, Map.put(bag, :episodes, episodes)}
  end

  def spawn_episodes(:audit, bag) do
    with {:ok, files}    <- File.ls(bag.input_dir),
         {:ok, episodes} <- audit_series_dir(files, bag) do
      episodes = merge_episode_lists(bag.episodes, episodes)
      {:ok, Map.put(bag, :episodes, episodes)}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unexpected Error When Conjuring Episodes"}
    end
  end

  def spawn_episodes(:spawn, bag = %Bag{ep_count: 0}), do: {:ok, bag}
  def spawn_episodes(:spawn, bag = %Bag{ep_count: nil}), do: {:ok, bag}
  def spawn_episodes(:spawn, bag) do
    episodes =
      1..(bag.ep_count)
      |> Enum.to_list()
      |> Enum.map(&spawn_episode/1)
      |> merge_episode_lists(bag.episodes)

    {:ok, Map.put(bag, :episodes, episodes)}
  end

  defp audit_series_dir(files, bag) do
    try do
      episodes =
        files
        |> Enum.filter(&(Regex.match?(bag.regex, &1)))
        |> Enum.map(fn filename ->
            {num, _} =
              Regex.named_captures(bag.regex, filename)["num"]
              |> Float.parse()
            spawn_episode(num, filename)
          end)

      {:ok, episodes}
    rescue
      _ in MatchError -> {:error, "Failed to parse episode filename"}
    end
  end

  defp merge_episode_lists(eps_1, eps_2) do
    groups = Enum.group_by(eps_1 ++ eps_2, &(&1.number))
    Enum.map(groups, fn {_, eps} ->
      Enum.reduce(eps, fn ep1, ep2 ->
        merge_episodes(ep1, ep2)
      end)
    end)
  end

  defp merge_episodes(ep1, ep2) do
    Map.merge(ep1, ep2, fn _k, v1, v2 ->
      case v1 do
        "Episode" <> _ -> v2
        nil -> v2
        _ -> v1
      end
    end)
  end

  ## Image Handling
  def conjure_images(bag = %Bag{}) do
    with :ok <- File.mkdir_p(bag.output_dir),
         :ok <- File.mkdir_p(bag.input_dir),
         :ok <- File.cd(bag.output_dir),
         :ok <- File.mkdir_p(bag.poster_dir),
         :ok <- File.mkdir_p(bag.cover_dir),
         {:ok, bag} <- conjure_poster_images(bag),
         {:ok, bag} <- conjure_cover_images(bag),
         #:ok <- File.cd(Application.app_dir(:animu)) do
         :ok <- File.cd("/home/ethan/src/proj/animu") do
      {:ok, bag}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unexpected Error When Conjuring Series Images"}
    end
  end

  defp conjure_poster_images(bag = %Bag{poster_image: nil}), do: {:ok, bag}
  defp conjure_poster_images(bag = %Bag{poster_image: %{}}), do: {:ok, bag}
  defp conjure_poster_images(bag = %Bag{}) do
    IO.puts "Conjuring Poster Images"
    orig_path = Path.join(bag.poster_dir, "original.jpg")
    sizes =
      %{ "large"  => {550, 780},
         "medium" => {390, 554},
         "small"  => {284, 402},
         "tiny"   => {110, 156},
      }

    with :ok <- File.cd(bag.output_dir),
         :ok <- write_image(orig_path, bag.poster_image),
         {:ok, images} <- conjure_thumbs(sizes, orig_path, bag.poster_dir) do
      images = Map.put(images, "original", orig_path)
      {_, 0} = ImageMagick.convert(orig_path, orig_path) # Ensures orig is jpg
      bag = Map.put(bag, :poster_image, images)
      {:ok, bag}
    end
  end

  defp conjure_cover_images(bag = %Bag{cover_image: nil}), do: {:ok, bag}
  defp conjure_cover_images(bag = %Bag{cover_image: %{}}), do: {:ok, bag}
  defp conjure_cover_images(bag = %Bag{}) do
    orig_path = Path.join(bag.cover_dir, "original.jpg")

    with :ok <- File.cd(bag.output_dir),
         :ok <- write_image(bag.cover_image, orig_path) do
      images = %{"original" => orig_path}
      {_, 0} = ImageMagick.convert(orig_path, orig_path) # Ensures orig is jpg
      bag = Map.put(bag, :cover_image, images)
      {:ok, bag}
    end
  end

  defp conjure_thumbs(sizes, orig, dir) do
    Enum.reduce_while(sizes, {:ok, %{}}, fn {name, size}, {:ok, acc} ->
      output = Path.join(dir, name <> ".jpg")
      case ImageMagick.resize(orig, output, size) do
        {_, 0} ->
          {:cont, {:ok, Map.put(acc, name, output)}}
        _ ->
          {:halt, {:error, "Resize of '#{orig}' to '#{output}' Failed"}}
      end
    end)
  end

  defp write_image(path, data) do
    case File.write(path, data) do
      :ok -> :ok
      {:error, _} ->
       {:error, "Failed To Write Image: '#{path}'"}
    end
  end

end

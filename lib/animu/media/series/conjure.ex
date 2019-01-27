defmodule Animu.Media.Series.Conjure do
  import Animu.Media.Episode.Conjure, only: [spawn_episode: 1, spawn_episode: 2]
  alias Animu.Media.Series.Bag
  alias Animu.Media.ImageMagick, as: Image

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
         :ok <- File.mkdir_p(Path.join(bag.output_dir, bag.poster_dir)),
         :ok <- File.mkdir_p(Path.join(bag.output_dir, bag.cover_dir)),
         {:ok, bag} <- conjure_poster_images(bag),
         {:ok, bag} <- conjure_cover_images(bag) do
      {:ok, bag}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unexpected Error When Conjuring Series Images"}
    end
  end

  defp conjure_poster_images(bag = %Bag{poster_image: nil}), do: {:ok, bag}
  defp conjure_poster_images(bag = %Bag{poster_image: %{}}), do: {:ok, bag}
  defp conjure_poster_images(bag = %Bag{}) do
    dir = bag.poster_dir
    dir_path = Path.join(bag.output_dir, bag.poster_dir)

    image = Path.join(bag.poster_dir, "original.jpg")
    image_path = Path.join(bag.output_dir, image)

    sizes =
      %{ "large"  => {550, 780},
         "medium" => {390, 554},
         "small"  => {284, 402},
         "tiny"   => {110, 156},
      }

    with           :ok <- Image.write_image(image_path, bag.poster_image),
         {:ok, images} <- Image.gen_thumbnails(image_path, dir_path, sizes),
                images <- prefix_thumbs(images, dir),
                images <- Map.put(images, "original", image),
                {_, 0} <- Image.convert(image_path, image_path) do

      {:ok, Map.put(bag, :poster_image, images)}
    end
  end

  defp conjure_cover_images(bag = %Bag{cover_image: nil}), do: {:ok, bag}
  defp conjure_cover_images(bag = %Bag{cover_image: %{}}), do: {:ok, bag}
  defp conjure_cover_images(bag = %Bag{}) do
    dir = bag.cover_dir
    dir_path = Path.join(bag.output_dir, bag.cover_dir)

    image = Path.join(bag.cover_dir, "original.jpg")
    image_path = Path.join(bag.output_dir, image)

    sizes = %{}

    with           :ok <- Image.write_image(image_path, bag.cover_image),
         {:ok, images} <- Image.gen_thumbnails(image_path, dir_path, sizes),
                images <- prefix_thumbs(images, dir),
                images <- Map.put(images, "original", image),
                {_, 0} <- Image.convert(image_path, image_path) do

      {:ok, Map.put(bag, :cover_image, images)}
    end
  end

  defp prefix_thumbs(thumbs, dir) do
    Map.new(thumbs, fn {name, file} ->
      {name, Path.join(dir, file)}
    end)
  end

end

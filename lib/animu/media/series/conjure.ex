defmodule Animu.Media.Series.Conjure do
  import Animu.Media.Episode.Conjure, only: [spawn_episode: 1, spawn_episode: 2]
  alias Animu.Media.Series.Bag

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

  def conjure_images(bag) do
    with :ok <- File.mkdir_p(bag.output_dir),
         :ok <- File.mkdir_p(bag.input_dir),
         :ok <- File.cd(bag.output_dir),
         :ok <- File.mkdir_p(bag.poster_dir),
         :ok <- File.mkdir_p(bag.cover_dir),
         {:ok, bag} <- conjure_poster_images(bag),
         {:ok, bag} <- conjure_cover_images(bag),
         :ok <- File.cd(Application.app_dir(:animu)) do
      {:ok, bag}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unexpected Error When Conjuring Series Images"}
    end
  end

  defp conjure_poster_images(bag) do
    poster_image =
      Enum.reduce_while(bag.poster_image, %{}, fn kv, acc ->
        write_image(kv, acc, bag.poster_dir)
      end)

    case poster_image do
      {:error, reason} -> {:error, reason}
      poster_image -> {:ok, Map.put(bag, :poster_image, poster_image)}
    end
  end

  defp conjure_cover_images(bag) do
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

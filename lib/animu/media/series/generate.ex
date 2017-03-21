defmodule Animu.Media.Series.Generate do

  alias Animu.Media.Series.KitsuFetcher

  def generate_files(series) do
    with {:ok, series} <- create_series_dirs(series),
          :ok          <- cd_series_output_dir(series),
         {:ok, series} <- create_image_dirs(series),
         {:ok, series} <- generate_poster_images(series),
         {:ok, series} <- generate_cover_images(series) do
      {:ok, series}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unexpected Error When Generating Series Files"}
    end
  end

  defp create_series_dirs(series) do
    with :ok <- File.mkdir_p(series.output_dir),
         :ok <- File.mkdir_p(series.input_dir) do
      {:ok, series}
    else
      {:error, _} -> {:error, "Failed To Generate Series Dir"}
    end
  end

  defp cd_series_output_dir(series) do
    case File.cd(series.output_dir) do
      :ok -> :ok
      {:error, _} -> {:error, "Failed To Change Dir To Series Output"}
    end
  end

  defp create_image_dirs(series) do
    with :ok <- File.mkdir_p(series.poster_dir),
         :ok <- File.mkdir_p(series.cover_dir) do
      {:ok, series}
    else
      {:error, _} -> {:error, "Failed To Generate Image Dir"}
    end
  end

  defp generate_poster_images(series) do
    poster_image =
      Map.new(series.poster_image, fn {k, v} ->
        write_image(k, v, series.poster_dir) end)

    case Map.to_list(poster_image) do
      [{:error, reason} | _] -> {:error, reason}
      _ -> {:ok, %{series | poster_image: poster_image}}
    end
  end

  defp generate_cover_images(series) do
    cover_image =
      Map.new(series.cover_image, fn {k, v} ->
        write_image(k, v, series.cover_dir) end)

    case Map.to_list(cover_image) do
      [{:error, reason} | _] -> {:error, reason}
      _ -> {:ok, %{series | cover_image: cover_image}}
    end
  end

  defp write_image(key, data, dir) do
    filename = key <> ".jpg"
    path = Path.join(dir, filename)
    case File.write(path, data) do
      :ok ->
        {key, path}
      {:error, reason} ->
        IO.inspect reason
        {:error, "Failed To Create Image File"}
    end
  end

  def generate_episodes(series) do
    with {:ok, kitsu_ep} <- generate_episodes_from_kitsu(series),
         {:ok, exist_ep} <- generate_episodes_from_existing(series) do

      groups = Enum.group_by(kitsu_ep ++ exist_ep, &(&1.number))

      episodes =
        Enum.map(groups, fn {_, eps} ->
          Enum.reduce(eps, fn ep1, ep2 ->
            Map.merge(ep1, ep2, fn _k, v1, v2 ->
              case v1 do
                "Episode" <> _ -> v2
                nil -> v2
                _ -> v1
              end
            end)
          end)
        end)

			{:ok, %{series | episodes: episodes}}
    end
  end

	defp generate_episodes_from_kitsu(%{gen_kitsu_ep: false}), do: {:ok, []}
  defp generate_episodes_from_kitsu(series) do
    KitsuFetcher.get_kitsu_episode_data(series)
  end

	defp generate_episodes_from_existing(%{gen_exist_ep: false}), do: {:ok, []}
  defp generate_episodes_from_existing(series) do
		with {:ok, files}    <- list_series_output_files(series),
				 {:ok, episodes} <- search_files_with_regex(files, series.regex),
               episodes  <- gen_from_episode_count(episodes, series),
				 do: {:ok, episodes}
	end

  defp list_series_output_files(series) do
		case File.ls(series.input_dir) do
			{:error, _} -> {:error, "Failed to ls files in series output dir"}
			{:ok, files} -> {:ok, files}
		end
  end

	defp search_files_with_regex(files, regex) do
		try do
			episodes =
				files
				|> Enum.filter(&(Regex.match?(regex, &1)))
				|> Enum.map(&(format_match_to_episode(regex, &1)))

			{:ok, episodes}
		rescue
			_ in MatchError -> {:error, "Failed to parse episode filename"}
		end
	end

	defp format_match_to_episode(regex, filename) do
		{num, _} =
			Regex.named_captures(regex, filename)["num"]
			|> Float.parse

		%{title: "Episode #{num}",
		  number: num,
		  video_path: filename,
		 }
	end

  def gen_from_episode_count(episodes, series) do
    kitsu_count = series.kitsu_data.episode_count
    generated =
      case kitsu_count do
        nil -> gen_num_episodes(series.ep_count)
        _   -> gen_num_episodes(kitsu_count)
      end

    generated = Map.new(generated, fn ep -> {ep.number, ep} end)
    episodes  = Map.new(episodes,  fn ep -> {ep.number, ep} end)
    Map.merge(generated, episodes) |> Map.values()
  end

  defp gen_num_episodes(count) do
    Enum.map(1..count, fn num ->
      %{title: "Episode #{num/1}",
        number: num/1,
       }
    end)
  end
end

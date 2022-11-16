defmodule Animu.Media.Anime.Bag.Compile do
  alias Animu.Util.ImageMagick
  alias Animu.Media.Anime
  alias Anime.Bag

  @poster_dir "images/poster"
  @cover_dir  "images/cover"

  ## Compile Bag -> Series
  def compile(%Bag{valid?: false} = bag), do: {:error, bag.errors}
  def compile(%Bag{} = bag) do
    with     episodes <- compile_episodes(bag),
             summoned <- compile_summons(bag),
                anime <- compile_anime(bag, summoned, episodes),
                  :ok <- make_directory(bag),
         {:ok, anime} <- write_images(anime, bag) do

    {:ok, anime}
    else
      {:error, msg} -> {:error, msg}
      error ->
        msg = "unexpected error when compiling anime: #{inspect error}"
        {:ok, msg}
    end
  end

  # Compile -> Episodes
  defp compile_episodes(%Bag{} = bag) do
    {force, fallback} = summoned_eps(bag)

    fallback ++ bag.episodes ++ force
    |> merge_episode_lists
    |> post_process_episodes
  end

  defp summoned_eps(%Bag{} = bag) do
    groups =
      bag.summons
      |> Enum.group_by(&(&1.force))
      |> Map.put_new(true,  [])
      |> Map.put_new(false, [])

    force    = Enum.map(groups[true], &(&1.episodes))
    fallback = Enum.map(groups[false], &(&1.episodes))
    {force, fallback}
  end

  defp merge_episode_lists(ep_lists) do
    ep_lists
    |> Enum.concat
    |> Enum.filter(&Map.has_key?(&1, :number))
    |> Enum.group_by(&(&1.number))
    |> Enum.map(fn {_k, eps} ->
         Enum.reduce(eps, %{}, fn ep, acc ->
           merge_episodes(acc, ep)
         end)
       end)
    |> Enum.filter(&Map.has_key?(&1, :name))
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

  defp post_process_episodes(episodes) do
    Enum.map(episodes, fn ep ->
      fallback_rel_number(ep)
    end)
  end

  defp fallback_rel_number(%{number: num} = ep) do
    Map.put_new(ep, :rel_number, num)
  end
  defp fallback_rel_number(ep), do: ep

  # Compile -> Summons
  defp compile_summons(%Bag{} = bag) do
    groups = Enum.group_by(bag.summons, &(&1.force))
    force    = merge_summons(groups[true])
    fallback = merge_summons(groups[false])
    {force, fallback}
  end

  defp merge_summons([]),  do: %{}
  defp merge_summons(nil), do: %{}
  defp merge_summons(summons) do
    summons
    |> Enum.map(&(&1.data))
    |> Enum.reduce(fn sum, acc ->
      Map.merge(sum, acc)
    end)
  end

  # Compile -> Anime
  defp compile_anime(%Bag{} = bag, summoned, episodes) do
    {force, fallback} = summoned

    bag.params
    |> Map.merge(force)
    |> merge_if_nil(fallback)
    |> Map.put(:episodes, episodes)
  end

  defp merge_if_nil(anime1, anime2) do
    Map.merge(anime1, anime2, fn _k, v1, v2 ->
      case v1 do
        nil -> v2
          _ -> v1
      end
    end)
  end

  ## Writing

  # Write -> Directory
  defp make_directory(bag = %Bag{}) do
    with :ok <- File.mkdir_p(bag.output_dir),
         :ok <- File.mkdir_p(bag.input_dir) do
      :ok
    else
      {:error, reason} -> {:error, reason}
      error ->
        msg = "unexpected error while making anime directory #{inspect error}"
        {:error, msg}
    end
  end

  # Write -> Images
  defp write_images(anime, bag = %Bag{}) do
    with :ok <- File.mkdir_p(Path.join(bag.output_dir, @poster_dir)),
         :ok <- File.mkdir_p(Path.join(bag.output_dir, @cover_dir)),
         {:ok, anime} <- write_poster_images(anime, bag),
         {:ok, anime} <- write_cover_images(anime, bag) do
      {:ok, anime}
    else
      {:error, reason} -> {:error, reason}
      error ->
        msg = "unexpected error while writing anime images #{inspect error}"
        {:error, msg}
    end
  end

  defp write_images(binary, sizes, image, dir, output_dir) do
    dir_path   = Path.join(output_dir, dir)
    image_path = Path.join(output_dir, image)

    with           :ok <- ImageMagick.write_image(binary, image_path),
         {:ok, images} <- ImageMagick.gen_thumbnails(image_path, dir_path, sizes),
                images <- prefix_thumbs(images, dir),
                images <- Map.put(images, "original", image),
                {_, 0} <- ImageMagick.convert(image_path, image_path) do
      {:ok, images}
    else
      {:error, msg} -> {:error, msg}
      error ->
        msg = "unexpected error while writing #{image}: #{inspect error}"
        {:error, msg}
    end
  end

  defp write_poster_images(anime = %{poster_image: nil}, _bag), do: {:ok, anime}
  defp write_poster_images(anime = %{poster_image: %{}}, _bag), do: {:ok, anime}
  defp write_poster_images(anime = %{poster_image: binary}, bag) do
    dir = @poster_dir
    image = Path.join(@poster_dir, "original.jpg")
    output_dir = bag.output_dir

    sizes =
      %{ "large"  => {550, 780},
         "medium" => {390, 554},
         "small"  => {284, 402},
         "tiny"   => {110, 156},
      }

    case write_images(binary, sizes, image, dir, output_dir) do
      {:ok, images} -> {:ok, Map.put(anime, :poster_image, images)}
      {:error, msg} -> {:error, msg}
      error ->
        {:error, "unexpected error when writing poster images #{inspect error}"}
    end
  end
  defp write_poster_images(anime, _bag), do: {:ok, anime}

  defp write_cover_images(anime = %{cover_image: nil}, _bag), do: {:ok, anime}
  defp write_cover_images(anime = %{cover_image: %{}}, _bag), do: {:ok, anime}
  defp write_cover_images(anime = %{cover_image: binary}, bag) do
    dir = @cover_dir
    image = Path.join(@cover_dir, "original.jpg")
    output_dir = bag.output_dir

    sizes = %{}

    case write_images(binary, sizes, image, dir, output_dir) do
      {:ok, images} -> {:ok, Map.put(anime, :cover_image, images)}
      {:error, msg} -> {:error, msg}
      error ->
        {:error, "unexpected error when writing cover images #{inspect error}"}
    end
  end
  defp write_cover_images(anime, _bag), do: {:ok, anime}

  defp prefix_thumbs(thumbs, dir) do
    Map.new(thumbs, fn {name, file} ->
      {name, Path.join(dir, file)}
    end)
  end

end

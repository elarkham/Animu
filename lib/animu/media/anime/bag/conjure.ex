defmodule Animu.Media.Anime.Bag.Conjure do
  @moduledoc """
  Fills fields using parameters provided, usually for creating something
  new or writing to the filesystem
  """
  alias Animu.Media.Anime.{Bag, Episode}
  alias Animu.Util.ImageMagick, as: Image

  ## Episode Conjuring
  def episode(%{type: "spawn", numbers: numbers}, %Bag{} = bag) do
    episodes = Enum.map(numbers, &Episode.new/1)
    bag = Map.put(bag, :episodes, bag.episodes ++ [episodes])

    {:ok, bag}
  end
  def episode(%{type: "conjure_video", numbers: numbers}, %Bag{} = bag) do
    episodes =
      bag.data.episodes
      |> Enum.filter(&Enum.member?(numbers, &1.number))

    {pending, golems} =
      episodes
      |> Enum.map(&Episode.conjure_video_lazy/1)
      |> Enum.unzip

    bag =
      bag
      |> Map.put(:golems,  golems  ++ bag.golems)
      |> Map.put(:pending, pending ++ bag.pending)

    {:ok, bag}
  end
  #def episode(%{type: "conjure_thumbs", numbers: numbers}, %Bag{} = bag) do
  #  episodes =
  #    bag.episodes
  #    |> Enum.filter(&Enum.member?(numbers, &1))

  #  {pending, golems} =
  #    episodes
  #    |> Enum.map(&Episode.conjure_video_thumbs_async/1)
  #    |> Enum.unzip

  #  bag =
  #    bag
  #    |> Map.put(:golems,  golems  ++ bag.golems)
  #    |> Map.put(:pending, pending ++ bag.pending)

  #  {:ok, bag}
  #end
  def episode(_, %Bag{} = bag), do: {:ok, bag}

  ## Image Handling
  def image(_, %Bag{} = bag), do: {:ok, bag}
  #def conjure_images(bag = %Bag{}) do
  #  with :ok <- File.mkdir_p(bag.output_dir),
  #       :ok <- File.mkdir_p(bag.input_dir),
  #       :ok <- File.mkdir_p(Path.join(bag.output_dir, bag.poster_dir)),
  #       :ok <- File.mkdir_p(Path.join(bag.output_dir, bag.cover_dir)),
  #       {:ok, bag} <- conjure_poster_images(bag),
  #       {:ok, bag} <- conjure_cover_images(bag) do
  #    {:ok, bag}
  #  else
  #    {:error, reason} -> {:error, reason}
  #    _ -> {:error, "Unexpected Error When Conjuring Anime Images"}
  #  end
  #end

  #defp conjure_poster_images(bag = %Bag{poster_image: nil}), do: {:ok, bag}
  #defp conjure_poster_images(bag = %Bag{poster_image: %{}}), do: {:ok, bag}
  #defp conjure_poster_images(bag = %Bag{}) do
  #  dir = bag.poster_dir
  #  dir_path = Path.join(bag.output_dir, bag.poster_dir)

  #  image = Path.join(bag.poster_dir, "original.jpg")
  #  image_path = Path.join(bag.output_dir, image)

  #  sizes =
  #    %{ "large"  => {550, 780},
  #       "medium" => {390, 554},
  #       "small"  => {284, 402},
  #       "tiny"   => {110, 156},
  #    }

  #  with           :ok <- Image.write_image(image_path, bag.poster_image),
  #       {:ok, images} <- Image.gen_thumbnails(image_path, dir_path, sizes),
  #              images <- prefix_thumbs(images, dir),
  #              images <- Map.put(images, "original", image),
  #              {_, 0} <- Image.convert(image_path, image_path) do

  #    {:ok, Map.put(bag, :poster_image, images)}
  #  end
  #end

  #defp conjure_cover_images(bag = %Bag{cover_image: nil}), do: {:ok, bag}
  #defp conjure_cover_images(bag = %Bag{cover_image: %{}}), do: {:ok, bag}
  #defp conjure_cover_images(bag = %Bag{}) do
  #  dir = bag.cover_dir
  #  dir_path = Path.join(bag.output_dir, bag.cover_dir)

  #  image = Path.join(bag.cover_dir, "original.jpg")
  #  image_path = Path.join(bag.output_dir, image)

  #  sizes = %{}

  #  with           :ok <- Image.write_image(image_path, bag.cover_image),
  #       {:ok, images} <- Image.gen_thumbnails(image_path, dir_path, sizes),
  #              images <- prefix_thumbs(images, dir),
  #              images <- Map.put(images, "original", image),
  #              {_, 0} <- Image.convert(image_path, image_path) do

  #    {:ok, Map.put(bag, :cover_image, images)}
  #  end
  #end

  #defp prefix_thumbs(thumbs, dir) do
  #  Map.new(thumbs, fn {name, file} ->
  #    {name, Path.join(dir, file)}
  #  end)
  #end

end

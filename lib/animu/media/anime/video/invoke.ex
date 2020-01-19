defmodule Animu.Media.Anime.Video.Invoke do

  import Animu.Media.Anime.Video.{Collect, Conjure, Transmute}
  alias Animu.Media.Anime.Video.Bag

  def new(golem, input_path, anime_dir) do
    with       bag  <- Bag.new(input_path, anime_dir),
         {:ok, bag} <- collect_input_data(bag),
         {:ok, bag} <- conjure_output(golem, bag),
         {:ok, bag} <- conjure_thumbnails(bag),
         {:ok, bag} <- collect_output_data(bag),
             video  <- transmute(bag, :video) do
      {:ok, video}
    else
      {:error, reason} -> {:error, reason}
      error ->
        {:error, "unexpected error when creating video: #{inspect(error)}"}
    end
  end
end

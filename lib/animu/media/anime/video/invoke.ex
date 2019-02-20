defmodule Animu.Media.Anime.Video.Invoke do

  import Animu.Media.Anime.Video.{Collect, Conjure, Transmute}
  alias Animu.Media.Anime.Video.Bag

  def new(input_path, anime_dir) do
    with       bag  <- Bag.new(input_path, anime_dir),
         {:ok, bag} <- collect_input_data(bag),
         {:ok, bag} <- conjure_output(bag),
         {:ok, bag} <- conjure_thumbnails(bag),
         {:ok, bag} <- collect_output_data(bag),
             video  <- transmute(bag, :video) do
      {:ok, video}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unexpected Error When Invoking Video"}
    end
  end

end
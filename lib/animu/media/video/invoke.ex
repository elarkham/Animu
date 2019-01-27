defmodule Animu.Media.Video.Invoke do

  import Animu.Media.Video.{Collect, Conjure, Transmute}

  alias Animu.Media.Video.Bag

  def new(input_path, series_dir) do
    with       bag  <- Bag.new(input_path, series_dir),
         {:ok, bag} <- collect_input_data(bag),
         {:ok, bag} <- conjure_output(bag),
         #        {:ok, bag} <- conjure_thumbnails(bag),
         {:ok, bag} <- collect_output_data(bag),
             video  <- transmute(bag, :video) do
      {:ok, video}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unexpected Error When Invoking Video"}
    end
  end

end

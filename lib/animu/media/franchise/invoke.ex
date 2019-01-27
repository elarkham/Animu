defmodule Animu.Media.Franchise.Invoke do
  import Ecto.Changeset

  import Animu.Media.Franchise.Validate
  import Animu.Media.Franchise.Collect
  import Animu.Media.Franchise.Conjure
  import Animu.Media.Franchise.Transmute

  alias Ecto.Changeset
  alias Animu.Media.Franchise

  def summon_images(%Franchise{} = franchise) do
    with       bag  <- transmute(franchise, :bag),
         {:ok, bag} <- download_poster_data(bag),
         {:ok, bag} <- download_cover_data(bag),
         {:ok, bag} <- conjure_images(bag),
         franchise  <- transmute(bag, :franchise) do

      {:ok, franchise}
    else
      {:error, reason} -> {:error, reason}
      error -> {:error, "Unexpected Error: #{error}"}
    end
	end
  def summon_images(changeset = %Changeset{valid?: false}), do: changeset
  def summon_images(changeset = %Changeset{changes: %{poster_url: nil, cover_url: nil}}), do: changeset
  def summon_images(changeset = %Changeset{}) do
    with       franchise  <- transmute(changeset, :franchise),
         {:ok, franchise} <- summon_images(franchise),
               changeset  <- transmute(franchise, changeset) do
      changeset
    else
      {:error, reason} ->
        add_error(changeset, :summon_images, reason)
    end
  end

end

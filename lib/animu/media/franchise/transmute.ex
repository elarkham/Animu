defmodule Animu.Media.Franchise.Transmute do

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Animu.Media.Franchise
  alias Animu.Media.Franchise.Bag
  alias Animu.Schema

  def transmute(%Changeset{} = changeset, :franchise) do
    %Franchise{} = apply_changes(changeset)
  end

  def transmute(%Franchise{} = franchise, :bag) do
    Bag.new(franchise)
  end

  def transmute(%Bag{} = bag, :franchise) do
    bag.data
    |> Map.put(:poster_image, bag.poster_image)
    |> Map.put(:cover_image, bag.cover_image)
  end

  def transmute(%Franchise{} = franchise, %Changeset{} = changeset) do
    changeset.data
      |> cast(Schema.to_params(franchise), Schema.all_fields(Franchise))
      |> merge(changeset)
  end

end

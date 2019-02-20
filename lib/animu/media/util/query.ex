defmodule Animu.Media.Query do
  @moduledoc """
  Reusable media querys
  """
  use Animu.Util.Query

  @doc """
  Allows for all keys in the Media context to be queried
  """
  defquery key, value do
    query
    |> Query.where([r], field(r, ^String.to_existing_atom(key)) == ^value)
  end
end

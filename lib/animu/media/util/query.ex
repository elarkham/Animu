defmodule Animu.Media.Query do
  @moduledoc """
  Reusable media querys
  """
  alias Animu.Util.Query
  alias Animu.Repo

  defdelegate build_query(query, params), to: Query

  def load_assoc(list, module, %{"preload" => fields}) do
    assoc = module.__schema__(:associations)
    fields =
      fields
      |> Enum.map(&String.to_existing_atom/1)
      |> Enum.filter(&Enum.member?(assoc, &1))
      |> IO.inspect()

    Repo.preload(list, fields)
    |> IO.inspect()
  end
  def load_assoc(list,_,_), do: list

end

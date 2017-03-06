defmodule Animu.ModelHelper do
  @doc """
  Only merges fields that are not currently nil, this is good for when you are
  pulling data from two incomplete sources.
  """
  def soft_merge(s1, s2) do
    struct(Map.merge(s1, s2, fn(_k, v1, v2) ->
      case v2 do
        nil -> v1
        _ -> v2
      end
    end))
  end

  @doc """
  Typically used for premade models that have not been inserted into a
  changeset yet.
  """
  def to_map(struct) do
    Map.from_struct(struct)
    |> Map.delete(:__meta__)
  end
end

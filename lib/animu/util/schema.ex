defmodule Animu.Util.Schema do

  def all_fields(module, opt \\ []) do
    defaults = %{as: :atom, except: [], assoc: false}
    %{as: type, except: rm_fields, assoc: assoc} = Enum.into(opt, defaults)

    fields = module.__schema__(:fields)

    fields =
      case assoc do
        true -> module.__schema__(:associations) ++ fields
           _ -> fields
      end

    fields =
      Enum.reduce(rm_fields, fields, fn field, acc ->
          List.delete(acc, field)
        end)

    case type do
        :both -> Enum.map(fields, &to_string/1) ++ fields
      :string -> Enum.map(fields, &to_string/1)
            _ -> fields
    end
  end

  def all_assoc(module, opt \\ []) do
    module.__schema__(:associations)
  end

  @drop [
    :__struct__, :__schema__, :__meta__,
    :__cardinality__, :__field__, :__owner__,
    :inserted_at, :updated_at
  ]

  def to_map(%Date{} = date), do: date
  def to_map(%Time{} = time), do: time
  def to_map(%DateTime{} = dt), do: dt
  def to_map(%{} = schema) do
    map =
      schema
      |> Map.drop(@drop)
      |> Enum.filter(fn {_k, v} ->
          not match?(%Ecto.Association.NotLoaded{}, v)
         end)
      |> Map.new

    Enum.reduce(map, map, fn {key, value}, map ->
      case value do
        nil -> Map.delete(map, key)

        v when is_map(v)  and map_size(v) <= 0 -> Map.delete(map, key)
        v when is_list(v) and length(v)   <= 0 -> Map.delete(map, key)

        v when is_map(v)  -> Map.put(map, key, to_map(v))
        v when is_list(v) -> Map.put(map, key, Enum.map(v, &to_map/1))
        _ -> map
      end
    end)
  end
  def to_map(value), do: value

end

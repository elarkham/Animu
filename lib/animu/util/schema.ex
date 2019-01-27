defmodule Animu.Schema do

  def all_fields(module, except: fields) do
    Enum.reduce(fields, module.__schema__(:fields), fn field, acc ->
      List.delete(acc, field)
    end)
  end

  def all_fields(module) do
    module.__schema__(:fields)
  end

  def to_params(schema) do
    params = Map.drop(schema, [:__struct__, :__schema__, :__meta__])
    Enum.reduce(params, params, fn {key, value}, params ->
      case value do
        nil -> Map.delete(params, key)
        _ -> params
      end
    end)
  end

end

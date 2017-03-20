defmodule Animu.Schema do

  def all_fields(module, except: fields) do
    Enum.reduce(fields, module.__schema__(:fields), fn i, acc ->
      List.delete(acc, i)
    end)
  end

  def all_fields(module) do
    module.__schema__(:fields)
  end
end

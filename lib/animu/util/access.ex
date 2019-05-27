defmodule Animu.Util.Access do
  @moduledoc """
  Implements the Access behaviour for arbitrary structs + schema
  """
  defmacro __using__(_opts) do
    quote do
      @behaviour Access

      defdelegate fetch(term, key), to: Map
      defdelegate pop(data, key, default \\ nil), to: Map
      defdelegate get_and_update(data, key, func), to: Map
    end
  end
end

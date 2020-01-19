defmodule Animu.Ecto.Type do

  defmodule Any do
    @behaviour Ecto.Type

    def type, do: :binary

    # To Changeset
    def cast(value) do
      {:ok, value}
    end

    # From Database
    def load(binary) when is_binary(binary) do
      {:ok, :erlang.binary_to_term(binary)}
    end

    # To Database
    def dump(term) do
      {:ok, :erlang.term_to_binary(term)}
    end
  end

  defmodule Atom do
    @behaviour Ecto.Type

    def type, do: :string

    # To Changeset
    def cast(value) when is_atom(value) do
      {:ok, value}
    end
    def cast(_), do: :error

    # From Database
    def load(string) when is_binary(string) do
      {:ok, String.to_atom(string)}
    end
    def load(_), do: :error

    # To Database
    def dump(value) when is_atom(value) do
      {:ok, to_string(value)}
    end
    def dump(value) when is_binary(value) do
      {:ok, value}
    end
    def dump(_), do: :error
  end
end

defmodule Animu.Util do
  alias Ecto.Changeset

  def if_nil(val, fallback) do
    case val do
      nil -> fallback
        _ -> val
    end
  end

  def date_now do
    DateTime.to_date(DateTime.utc_now())
  end

  def format_errors(%Changeset{} = ch) do
    Changeset.traverse_errors(ch, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_error_string(value))
      end)
    end)
  end
  defp to_error_string({type, inner_type}) do
    "{#{to_string(type)}, #{to_string(inner_type)}}"
  end
  defp to_error_string(type) do
    to_string(type)
  end

end

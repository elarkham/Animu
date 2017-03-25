defmodule Animu.Media.Series.Validate do

  alias Animu.Media.Series.Bag

  def validate_kitsu_id(%Bag{} = bag) do
    case bag do
      %{kitsu_id: nil} ->
        {:error, "Kitsu Id Is Required For Population"}
      %{kitsu_id: _} ->
        {:ok, bag}
    end
  end

  def validate_series_dir(%Bag{} = bag) do
    case bag do
      %{dir: nil} ->
        {:error, "Series Directory Is Required For Population"}
      %{dir: _} ->
        {:ok, bag}
    end
  end

  def validate_regex(bag) do
    with {:ok, bag} <- validate_regex_not_nil(bag),
         {:ok, bag} <- validate_regex_compiles(bag),
         do: {:ok, bag}
  end

  defp validate_regex_not_nil(bag) do
    case bag do
      %{regex: nil} ->
        {:error, "Regex Is Required For Audit"}
      %{regex: _} ->
        {:ok, bag}
    end
  end

  def validate_regex_compiles(bag = %Bag{regex: nil}), do: {:ok, bag}
  def validate_regex_compiles(bag) do
    case Regex.compile(bag.regex) do
      {:error, {error, num}} when is_integer(num) ->
        {:error, "Provided Regex Failed: #{error}"}
      {:ok, regex} ->
        {:ok, Map.put(bag, :regex, regex)}
    end
  end
end

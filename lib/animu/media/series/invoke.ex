defmodule Animu.Media.Series.Invoke do
  import Ecto.Changeset

  import Animu.Media.Series.Validate
  import Animu.Media.Series.Collect
  import Animu.Media.Series.Conjure
  import Animu.Media.Series.Transmute

  alias Ecto.Changeset
  alias Animu.Media.Series

  # Invoke Options
  def invoke(%Bag{} = bag) do
    Enum.reduce_while(bag.options, bag, fn opt, bag ->
      case invoke(bag, [opt]) do
           {:ok, bag} -> {:cont, bag}
        {:error, msg} -> {:halt, Bag.error(bag, msg)}

        error ->
          msg = "Unexpected Error During Invoke: #{error}"
          {:halt, Bag.error(bag, msg)}
      end
    end)
  end

  def invoke(%Bag{} = bag, summon: params) do
    summons =
      Enum.reduce_while(params, [], fn source, acc ->
        name = source.name
        {:ok, acc} = acc
        case Summon.summon(source, bag) do
            {:ok, data} -> {:cont, acc ++ [data]}
          {:error, msg} -> {:halt, {:error, %{^name => msg}}}
        end
      end)

    case summons do
      {:ok, summons} -> {:ok, Map.put(bag, :summons, summons)}
       {:error, msg} -> {:error, {"summon" => msg}}

      error ->
        {:error, "Unexpected Error During Summoning: #{error}"}
    end
  end

  def invoke(%Bag{} = bag, audit: params) do
    with {:ok, bag} <- Audit.scan(params, bag),
         {:ok, bag} <- Audit.calc(params, bag) do

      {:ok, bag}
    else
      {:error, msg} -> {:error, %{"audit" => msg}}

      error ->
        {:error, "Unexected Error During Audit: #{error}"}
    end
  end

  def invoke(%Bag{} = bag, conjure: params) do
    with {:ok, bag} <- Conjure.episodes(bag, params),
         {:ok, bag} <- Conjure.image(bag, params) do
    else
      {:error, msg} -> {:error, msg},

      error ->
        {:error, "Unexpected Error During Conjuring: #{error}"}
    end
  end

end

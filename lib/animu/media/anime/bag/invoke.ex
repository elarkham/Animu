defmodule Animu.Media.Anime.Bag.Invoke do
  import Ecto.Changeset

  alias Ecto.Changeset
  alias Animu.Media.Anime
  alias Animu.Media.Anime.Bag

  alias Animu.Media.Anime.Bag.{Audit, Conjure, Summon}

  # Cleanup
  defp cleanup

  # Invoke Options
  defp invoke_options(%Bag{} = bag) do
    Enum.reduce_while(bag.options, bag, fn opt, bag ->
      case invoke(bag, [opt]) do
           {:ok, bag} -> {:cont, bag}
        {:error, msg} -> {:halt, Bag.error(bag, msg)}

        error ->
          msg = "Unexpected Error During Invoke: #{inspect(error)}"
          {:halt, Bag.error(bag, msg)}
      end
    end)
  end

  def invoke(%Bag{} = bag) do
    bag
    |> invoke_options
    |> cleanup
  end

  defp invoke(%Bag{} = bag, summon: params) do
    summons =
      Enum.reduce_while(params, {:ok, []}, fn source, acc ->
        name = source.source
        {:ok, acc} = acc
        case Summon.summon(source, bag) do
            {:ok, data} -> {:cont, {:ok, acc ++ [data]}}
          {:error, msg} -> {:halt, {:error, %{name => msg}}}
        end
      end)

    case summons do
      {:ok, summons} ->
        bag =
          bag
          |> Summon.compile_genres(summons)
          |> Map.put(:summons, summons)
        {:ok, bag}

      {:error, msg} ->
        {:error, %{"summon" => msg}}
      error ->
        {:error, "Unexpected Error During Summoning: #{inspect(error)}"}
    end
  end

  defp invoke(%Bag{} = bag, audit: params) do
    with {:ok, bag} <- Audit.scan(params, bag),
         {:ok, bag} <- Audit.calc(params, bag) do

      {:ok, bag}
    else
      {:error, msg} -> {:error, %{"audit" => msg}}
      error ->
        {:error, "Unexected Error During Audit: #{inspect(error)}"}
    end
  end

  defp invoke(%Bag{} = bag, conjure: params) do
    with {:ok, bag} <- Conjure.episode(params[:episode], bag),
         {:ok, bag} <- Conjure.image(params[:image], bag) do

      {:ok, bag}
    else
      {:error, msg} -> {:error, msg}
      error ->
        {:error, "Unexpected Error During Conjuring: #{inspect(error)}"}
    end
  end

end

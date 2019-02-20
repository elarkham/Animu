defmodule Animu.Media.Anime.Bag.Invoke do
  import Ecto.Changeset

  alias Ecto.Changeset
  alias Animu.Media.Anime
  alias Animu.Media.Anime.Bag

  alias Animu.Media.Anime.Bag.{Audit, Conjure, Summon}

  def invoke(%Bag{} = bag) do
    Enum.reduce_while(bag.options, bag, fn opt, bag ->
      case invoke(bag, [opt]) do
        {:ok, bag}    -> {:cont, bag}
        {:error, msg} -> {:halt, Bag.error(bag, msg)}

        error ->
          msg = "unexpected error during invoke: #{inspect(error)}"
          {:halt, Bag.error(bag, msg)}
      end
    end)
  end

  # Audit
  defp invoke(%Bag{} = bag, audit: params) do
    with {:ok, bag} <- Audit.scan(params, bag),
         {:ok, bag} <- Audit.calc(params, bag) do

      {:ok, bag}
    else
      {:error, msg} -> {:error, %{"audit" => msg}}
      error ->
        {:error, "unexected error during audit: #{inspect(error)}"}
    end
  end

  # Conjure
  defp invoke(%Bag{} = bag, conjure: params) do
    with {:ok, bag} <- Conjure.episode(params[:episode], bag),
         {:ok, bag} <- Conjure.image(params[:image], bag) do

      {:ok, bag}
    else
      {:error, msg} -> {:error, %{"conjure" => msg}}
      error ->
        {:error, "unexpected error during conjuring: #{inspect(error)}"}
    end
  end

  # Summon
  defp invoke(%Bag{} = bag, summon: params) do
    with {:ok, summons} <- Summon.gather(bag, params),
         {:ok, bag}     <- Summon.compile(bag, summons) do

      {:ok, bag}
    else
      {:error, msg} -> {:error, %{"summon" => msg}}
      error ->
        {:error, "unexpected error during summoning: #{inspect(error)}"}
    end
  end

end

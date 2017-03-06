defmodule Animu.QueryBuilder do

  alias Animu.Series
  alias Animu.Episode
  import Ecto.Query

  def build(Series, params) do
    Series
      |> build_orderBy(params)
      |> build_where(params)
      |> build_limit(params)
      |> select([s], s)
  end

  def build(Episode, params) do
    Episode
      |> build_orderBy(params)
      |> build_where(params)
      |> build_limit(params)
      |> select([e], e)
  end

  def build_orderBy(query, %{"orderBy" => field}) do
    field = String.to_existing_atom field
    query |> order_by(desc: ^field)
  end
  def build_orderBy(query, _), do: query

  def build_where(query, %{"where" => filters}) do
    filters =
      Enum.map(filters, fn {k, v} -> {String.to_existing_atom(k), v} end)

    IO.inspect filters
    query |> where(^filters)
  end
  def build_where(query, _), do: query

  def build_limit(query, %{"limit" => num}) do
    num = String.to_integer num
    query |> limit(^num)
  end
  def build_limit(query, _), do: query

  def build_preload(query, Series, %{"preload" => "true"}) do
    query
      |> preload(:episodes)
      |> preload(:franchises)
  end
  def build_preload(query, Episode, %{"preload" => "true"}) do
    query
      |> preload(:series)
  end
  def build_preload(query, _, _), do: query
end

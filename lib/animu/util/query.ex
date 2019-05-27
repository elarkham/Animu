defmodule Animu.Util.Query do
  @moduledoc """
  Defines query handlers that could be used in any context.
  Allows for context specific queries to be handled in their own domains when needed.
  """
  import Ecto.Query, only: [from: 1], warn: false
  alias Ecto.Query

  def build_query(query, params = %{}) do
    params = Animu.Util.to_kwlist(params)
    build_query(query, params)
  end
  def build_query(query, params) when is_list(params) do
    IO.inspect params
    Enum.reduce(params, query, fn pair, q ->
      build_query(q, pair)
    end)
    |> build_select(params)
  end

  def build_select(query, params) when is_list(params) do
    Enum.reduce(params, query, fn pair, q ->
      build_select(q, pair)
    end)
  end

  ## Query Ops
  def build_query(q, {"limit", amount}) do
    Query.limit(q, ^amount)
  end

  def build_query(q, {"order_by", "-" <> field}) do
    field = String.to_existing_atom field
    Query.order_by(q, desc: ^field)
  end

  def build_query(q, {"order_by", "+" <> field}) do
    field = String.to_existing_atom field
    Query.order_by(q, asc: ^field)
  end

  def build_query(q, {"order_by", field}) do
    field = String.to_existing_atom field
    Query.order_by(q, asc: ^field)
  end

  def build_query(q, _), do: q

  ## Select Ops
  def build_select(q, {"fields", fields}) do
    fields = Enum.map(fields, &String.to_existing_atom/1)
    fields = fields ++ [:id] # id must always be included
    Query.select(q, ^fields)
  end
  def build_select(q, _), do: q
end

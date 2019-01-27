defmodule Animu.Query do
  @moduledoc """
  Defines query handlers that could be used in any context.
  Allows for context specific queries to be handled in their own domains when needed.
  """
  defmacro __using__(_opts) do
    quote do
      use Inquisitor

      import Ecto.Query, only: [from: 1], warn: false
      alias Ecto.Query

      def build_query(query,[{"limit", amount} | tail]) do
        query
        |> Query.limit(^amount)
				|> build_query(tail)
      end

      def build_query(query,[{"order_by", field} | tail]) do
        field = String.to_existing_atom field
        query
        |> Query.order_by(asc: ^field)
				|> build_query(tail)
      end

			def build_query(query,[{"preload", schema} | tail]) do
        schema = String.to_existing_atom schema
        query
        |> Query.preload(^schema)
				|> build_query(tail)
      end

			def build_query(query,[{"inserted_at", date} | tail]) do
        query
        |> Query.where([p], p.inserted_at >= ^date)
				|> build_query(tail)
      end

    end
  end

end

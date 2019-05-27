defmodule Animu.Ecto.Schema do
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      use Animu.Util.Access

      import Ecto.{Query, Changeset}, warn: false
      import Animu.Util.Schema

      alias Ecto.Changeset
      alias Animu.Repo

      @derive {Poison.Encoder, except: [:__meta__]}
      @timestamps_opts [type: :utc_datetime]
    end
  end
end

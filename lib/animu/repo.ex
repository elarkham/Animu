defmodule Animu.Repo do
  @moduledoc """
  Animu Repo
  """
  use Ecto.Repo,
    otp_app: :animu,
    adapter: Ecto.Adapters.Postgres
end

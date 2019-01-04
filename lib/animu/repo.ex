defmodule Animu.Repo do
  use Ecto.Repo,
    otp_app: :animu,
    adapter: Ecto.Adapters.Postgres
end

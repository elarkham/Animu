defmodule Animu.Repo.Migrations.CreateGolem do
  use Ecto.Migration

  def change do
    create table(:golem, primary_key: false) do
      add :id,    :uuid,  primary_key: true
      add :label, :binary

      add :status_type,  :string
      add :status_meta,  :binary

      add :progress_percent, :float
      add :progress_meta,    :binary

      add :attempts,  :integer
      add :failures,  :binary

      add :args, :binary
      add :chem, :string

      add :queued_at,  :utc_datetime
      add :started_at, :utc_datetime
      add :ended_at,   :utc_datetime
    end

  end
end

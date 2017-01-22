defmodule Animu.Repo.Migrations.SeriesAddWatchBoolean do
  use Ecto.Migration

  def change do
    alter table(:series) do
      add :watch, :boolean
    end
  end
end

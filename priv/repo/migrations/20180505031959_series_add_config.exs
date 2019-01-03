defmodule Animu.Repo.Migrations.SeriesAddConfig do
  use Ecto.Migration

  def change do
    alter table(:series) do
      add :config, :map
    end
  end
end

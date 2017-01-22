defmodule Animu.Repo.Migrations.SeriesAddFieldsForRSS do
  use Ecto.Migration

  def change do
    alter table(:series) do
      add :regex, :string
      add :subgroup, :string
      add :rss_feed, :string
      add :quality, :string
    end
  end
end

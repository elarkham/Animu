defmodule Animu.Repo.Migrations.SeriesEpisodeFranchiseIncreaseSynopsisSize do
  use Ecto.Migration

  def change do
    alter table(:franchises) do
      modify :synopsis, :text
    end

    alter table(:series) do
      modify :synopsis, :text
    end

    alter table(:episodes) do
      modify :synopsis, :text
    end

  end
end

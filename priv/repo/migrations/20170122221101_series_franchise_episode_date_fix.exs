defmodule Animu.Repo.Migrations.SeriesFranchiseEpisodeDateFix do
  use Ecto.Migration

  def change do
    alter table(:franchises) do
      modify :date_released, :date
    end

    alter table(:series) do
      modify :started_airing_date, :date
      modify :finished_airing_date, :date
    end

    alter table(:episodes) do
      modify :airdate, :date
    end
  end
end

defmodule Animu.Repo.Migrations.CreateSeason do
  use Ecto.Migration

  def change do
    create table(:season) do
      add :year, :integer
      add :cour, :citext

      add :name, :string
      add :slug, :citext
      add :sort, :citext
    end
    create unique_index(:season, [:cour, :year], name: :season_cour_year_index)
    create unique_index(:season, [:name])
    create unique_index(:season, [:slug])

    create table(:anime_season) do
      add :anime_id,  references(:anime,   on_delete: :delete_all)
      add :season_id, references(:season,  on_delete: :delete_all)
    end
  end

end

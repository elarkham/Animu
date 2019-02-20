defmodule Animu.Repo.Migrations.CreateSeason do
  use Ecto.Migration

  def change do
    create table(:seasons) do
      add :year,  :integer
      add :cour,  :citext

      add :name,  :string
      add :slug,  :citext
    end
    create unique_index(:seasons, [:cour, :year], name: :seasons_cour_year_index)
    create unique_index(:seasons, [:name])
    create unique_index(:seasons, [:slug])

    create table(:anime_seasons) do
      add :anime_id,  references(:anime,   on_delete: :delete_all)
      add :season_id, references(:seasons, on_delete: :delete_all)
    end
  end

end

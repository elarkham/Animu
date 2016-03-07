defmodule Animu.Repo.Migrations.CreateEpisode do
  use Ecto.Migration

  def change do
    create table(:episodes) do
      add :title, :string, null: false
      add :description, :string
      add :airdate, :datetime
      add :number, :integer, null: false
      add :season_number, :integer
      add :slug, :string, null: false
      add :tv_series_id, references(:tvseries, on_delete: :delete_all), null: false

      timestamps
    end

    create index(:episodes, [:tv_series_id])
    create unique_index(:episodes, [:title])
    create unique_index(:episodes, [:number])
    create unique_index(:episodes, [:slug])
  end
end

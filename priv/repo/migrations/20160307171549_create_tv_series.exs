defmodule Animu.Repo.Migrations.CreateTVSeries do
  use Ecto.Migration

  def change do
    create table(:tvseries) do
      add :titles, :map
      add :slug, :string
      add :started_airing, :date
      add :finished_airing, :date
      add :episode_count, :integer
      add :episode_length, :float
      add :poster_image, :map
      add :cover_image, :map
      add :hummingbird_rating, :float
      add :genres, {:array, :string}
      add :gallery, :map
      add :trailers, {:array, :string}
      add :description, :string
      add :age_rating, :string
      add :season_number, :integer
      add :tags, {:array, :string}
      add :franchise_id, references(:franchises, on_delete: :nothing)

      timestamps
    end

    create index(:tvseries, [:franchise_id])
    create unique_index(:tvseries, [:titles])
    create unique_index(:tvseries, [:slug])
  end
end

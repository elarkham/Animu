defmodule Animu.Repo.Migrations.CreateGenre do
  use Ecto.Migration

  def change do
    create table(:genres) do
      add :name,  :string
      add :slug,  :citext
      add :nsfw,  :boolean

      add :description, :text
      add :poster, {:map, :string}

      add :kitsu_id, :string
    end
    create unique_index(:genres, [:name])
    create unique_index(:genres, [:slug])

    create table(:anime_genres) do
      add :anime_id, references(:anime, on_delete: :delete_all)
      add :genre_id, references(:genres, on_delete: :delete_all)
    end
  end
end

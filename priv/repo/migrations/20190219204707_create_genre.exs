defmodule Animu.Repo.Migrations.CreateGenre do
  use Ecto.Migration

  def change do
    create table(:genre) do
      add :name,  :string
      add :slug,  :citext
      add :nsfw,  :boolean

      add :description, :text
      add :poster, {:map, :string}

      add :kitsu_id, :string
    end
    create unique_index(:genre, [:name])
    create unique_index(:genre, [:slug])

    create table(:anime_genre) do
      add :anime_id, references(:anime, on_delete: :delete_all)
      add :genre_id, references(:genre, on_delete: :delete_all)
    end
  end
end

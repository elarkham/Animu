defmodule Animu.Repo.Migrations.CreateFranchise do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION citext;"
    create table(:franchises) do
      add :name,          :string, null: false
      add :titles,        :map
      add :slug,          :citext, null: false

      add :creator,       :string
      add :synopsis,      :text

      add :directory,     :string, null: false

      add :cover_image,   {:map, :string}
      add :poster_image,  {:map, :string}

      add :tags,          {:array, :string}

      timestamps(type: :utc_datetime)
    end

    create unique_index(:franchises, [:slug])
  end
end

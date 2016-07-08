defmodule Animu.Repo.Migrations.CreateFranchise do
  use Ecto.Migration

  def change do
    create table(:franchises) do
      add :titles,          :map,    null: false
      add :creator,         :string
      add :description,     :string
      add :slug,            :string, null: false

      add :cover_image,     :map
      add :poster_image,    :map
      add :gallery,         :map

      add :trailers,        {:array, :string}
      add :tags,            {:array, :string}

      add :date_released, :datetime
      timestamps()
    end

    create unique_index(:franchises, [:slug])
  end
end

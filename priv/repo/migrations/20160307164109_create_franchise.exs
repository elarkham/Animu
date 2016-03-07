defmodule Animu.Repo.Migrations.CreateFranchise do
  use Ecto.Migration

  def change do
    create table(:franchises) do
      add :titles,        :map,    null: false
      add :creator,       :string, null: true
      add :description,   :string, null: true
      add :slug,          :string, null: false

      add :cover_image,   :map,    null: true
      add :poster_image,  :map,    null: true
      add :gallery,       :map,    null: true

      add :trailers,      {:array, :string}
      add :tags,          {:array, :string}

      add :date_released, :datetime
      timestamps
    end

  end
end

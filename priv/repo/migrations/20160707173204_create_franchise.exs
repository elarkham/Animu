defmodule Animu.Repo.Migrations.CreateFranchise do
  use Ecto.Migration

  def change do
    create table(:franchises) do
      add :titles, :map
      add :creator, :string
      add :description, :string
      add :slug, :string
      add :cover_image, :map
      add :poster_image, :map
      add :gallery, :map
      add :trailers, {:array, :string}
      add :tags, {:array, :string}

      timestamps()
    end

  end
end

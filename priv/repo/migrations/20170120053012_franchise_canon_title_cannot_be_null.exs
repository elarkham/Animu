defmodule Animu.Repo.Migrations.FranchiseCanonTitleCannotBeNull do
  use Ecto.Migration

  def change do
    alter table(:franchises) do
      modify :canon_title, :string, null: false
      modify :titles,   {:map, :string}, null: true
    end
  end
end

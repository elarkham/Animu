defmodule Animu.Repo.Migrations.FranchiseAddDirectory do
  use Ecto.Migration

  def change do
    alter table(:franchises) do
      add :directory, :string
    end
  end
end

defmodule Animu.Repo.Migrations.EpisodeAllowNullVideoField do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
       modify :video, :string, null: true
    end
  end
end

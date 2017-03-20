defmodule Animu.Repo.Migrations.EpisodeChangeVideoTypeToJsonb do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
       remove :video
       add :video, :map, null: true
    end
  end
end

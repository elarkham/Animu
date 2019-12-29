defmodule Animu.Repo.Migrations.CreateEpisode do
  use Ecto.Migration

  def change do
    create table(:episode) do
      add :name,     :string, null: false
      add :titles,   :string
      add :synopsis, :text

      add :kitsu_id, :string

      add :number,     :float, null: false
      add :rel_number, :float

      add :airdate,    :date
      add :augured_at, :utc_datetime

      add :anime_id, references(:anime, on_delete: :delete_all), null: false
      add :video,    :map

      timestamps(type: :utc_datetime)
    end
    create unique_index(:episode, [:number, :anime_id], name: :episode_number_anime_id_index)

  end
end

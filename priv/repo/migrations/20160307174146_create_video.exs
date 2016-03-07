defmodule Animu.Repo.Migrations.CreateVideo do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add :filename, :string, null: false
      add :path, :string
      add :format_name, :string
      add :duration, :float
      add :size, :integer
      add :stream_count, :integer
      add :thumbnail, :string
      add :quality, :string
      add :episode_id, references(:episodes, on_delete: :delete_all)

      timestamps
    end
    create index(:videos, [:episode_id])

  end
end

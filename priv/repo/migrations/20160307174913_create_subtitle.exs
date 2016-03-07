defmodule Animu.Repo.Migrations.CreateSubtitle do
  use Ecto.Migration

  def change do
    create table(:subtitle) do
      add :type, :string
      add :path, :string, null: false
      add :fonts, {:array, :string}
      add :audio_stream_index, :integer
      add :video_id, references(:videos, on_delete: :delete_all), null: false

      timestamps
    end
    create index(:subtitle, [:video_id])

  end
end

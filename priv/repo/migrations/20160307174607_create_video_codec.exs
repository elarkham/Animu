defmodule Animu.Repo.Migrations.CreateVideoCodec do
  use Ecto.Migration

  def change do
    create table(:videocodec) do
      add :stream_index, :integer, null: false
      add :codec_name, :string
      add :width, :integer
      add :height, :integer
      add :bitrate, :integer
      add :profile, :string
      add :video_id, references(:videos, on_delete: :delete_all), null: false

      timestamps
    end
    create index(:videocodec, [:video_id])

  end
end

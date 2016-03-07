defmodule Animu.Repo.Migrations.CreateAudioCodec do
  use Ecto.Migration

  def change do
    create table(:audiocodec) do
      add :stream_index, :integer, null: false
      add :codec_name, :string
      add :bitrate, :integer
      add :profile, :string
      add :language, :string
      add :disposition, :string
      add :channels, :integer
      add :channel_layout, :string
      add :video_id, references(:videos, on_delete: :delete_all), null: false

      timestamps
    end
    create index(:audiocodec, [:video_id])

  end
end

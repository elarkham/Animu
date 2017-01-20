defmodule Animu.Repo.Migrations.CreateSeriesAndEpisodeAlterFranchise do
  use Ecto.Migration

  def change do
    create table(:series) do
      add :canon_title,    :string, null: false
      add :titles,         {:map, :string}
      add :synopsis,       :string
      add :slug,           :string, null: false

      add :cover_image,    {:map, :string}
      add :poster_image,   {:map, :string}
      add :gallery,        {:map, :string}

      add :trailers,       {:array, :string}
      add :tags,           {:array, :string}
      add :genres,         {:array, :string}

      add :age_rating,     :string
      add :nsfw,           :boolean

      add :season_number,  :integer
      add :episode_count,  :integer
      add :episode_length, :integer

      add :kitsu_rating,   :float
      add :kitsu_id,       :string

      add :directory,      :string, null: false

      add :started_airing_date,  :naive_datetime
      add :finished_airing_date, :naive_datetime

      add :franchise_id, references(:franchises)

      timestamps()
    end

    create unique_index(:series, [:slug])

    create table(:episodes) do
      add :title,         :string
      add :synopsis,      :string
      add :thumbnail,     {:map, :string}
      add :kitsu_id,      :string

      add :number,        :float, null: false
      add :season_number, :integer
      add :airdate,       :naive_datetime

      add :video,     :string, null: false
      add :subtitles, :string

      add :series_id, references(:series, on_delete: :delete_all), null: false

      timestamps()
    end

    alter table(:franchises) do
      add :canon_title, :string, null: true
      modify :titles,   {:map, :string}, null: false
    end

    rename table(:franchises), :description, to: :synopsis
  end
end

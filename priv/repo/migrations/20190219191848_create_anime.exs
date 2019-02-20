defmodule Animu.Repo.Migrations.CreateAnime do
  use Ecto.Migration

  def change do
    create table(:anime) do
      ## Meta Data
      add :name,         :string, null: false
      add :titles,       {:map, :string}
      add :synopsis,     :text
      add :slug,         :citext, null: false

      add :directory,    :string, null: false

      add :cover_image,  {:map, :string}
      add :poster_image, {:map, :string}
      add :gallery,      {:map, :string}

      add :trailers,     {:array, :string}
      add :tags,         {:array, :string}

      add :nsfw,         :boolean
      add :age_rating,   :string
      add :age_guide,    :string

      ## External Data
      add :kitsu_rating, :float
      add :kitsu_id,     :string

      add :mal_id,       :string
      add :tvdb_id,      :string
      add :anidb_id,     :string

      ## Franchise Data
      add :franchise_id, references(:franchises)
      add :subtitle,     :string
      add :subtype,      :citext, null: false, default: "tv"
      add :number,       :integer, default: 1

      ## Episode Data
      add :episode_count,  :integer
      add :episode_length, :integer

      ## Augur Data
      add :augur,      :boolean, default: false
      add :augured_at, :utc_datetime

      add :regex,      :string
      add :rss_feed,   :string
      add :subgroup,   :string
      add :quality,    :string

      ## Time Data
      add :airing,     :date
      add :airing_at,  :map

      add :start_date,  :date
      add :end_date,    :date

      timestamps(type: :utc_datetime)
    end

    create unique_index(:anime, [:slug])
  end
end

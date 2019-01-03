defmodule Animu.Media.Series do
  use Ecto.Schema

  alias Animu.Media.{Episode, Franchise, Upload}

  @derive {Poison.Encoder, except: [:__meta__]}
  schema "series" do
    field :canon_title,    :string
    field :titles,         {:map, :string}
    field :synopsis,       :string
    field :slug,           :string

    field :cover_image,    Upload.Image
    field :poster_image,   Upload.Image
    field :gallery,        {:map, :string}

    field :trailers,       {:array, :string}
    field :tags,           {:array, :string}
    field :genres,         {:array, :string}

    field :age_rating,     :string
    field :nsfw,           :boolean

    field :season_number,  :integer
    field :episode_count,  :integer
    field :episode_length, :integer

    has_many   :episodes,   Episode, defaults: [], on_replace: :delete
    belongs_to :franchise,  Franchise

    field :kitsu_rating,   :float
    field :kitsu_id,       :string

    field :regex,          :string
    field :subgroup,       :string
    field :quality,        :string
    field :rss_feed,       :string
    field :watch,          :boolean #, default: false

    field :directory,      :string

    field :started_airing_date,  :date
    field :finished_airing_date, :date

    # Virtual Fields
    field :populate,       :boolean, virtual: true
    field :audit,          :boolean, virtual: true
    field :spawn_episodes, :boolean, virtual: true

    timestamps()
  end


end

defmodule Animu.Media.Series do
  use Ecto.Schema

  alias Animu.Media.{Episode, Franchise}
  alias Animu.Util.Image

  @derive {Poison.Encoder, except: [:__meta__]}
  schema "series" do

    ## Meta Data
    field :canon_title,    :string
    field :titles,         {:map, :string}
    field :synopsis,       :string
    field :slug,           :string

    field :directory,      :string

    field :cover_image,    Image
    field :poster_image,   Image
    field :gallery,        {:map, :string}

    field :trailers,       {:array, :string}
    field :tags,           {:array, :string}

    #TODO NEW
    many_to_many :genre, Genre,
      join_through: "series_genres",
      defaults: []

    field :nsfw,           :boolean

    field :age_rating,     :string
    field :age_guide,      :string #TODO NEW

    ## External Data
    field :kitsu_rating,   :float
    field :kitsu_id,       :string

    field :mal_id,         :string #TODO NEW
    field :tvdb_id,        :string #TODO NEW
    field :anidb_id,       :string #TODO NEW

    ## Franchise Data
    belongs_to :franchise, Franchise
    field :subtitle        :string  #TODO NEW
    field :subtype,        :string  #TODO maybe?

    field :season_number,  :integer #TODO Remove?
    field :number,         :integer # <- Rename to this?

    ## Episode Data
    has_many   :episodes,  Episode,
      on_replace: :delete,
      defaults: []

    field :episode_count,  :integer
    field :episode_length, :integer

    ## Augur Data
    #field :watch           :boolean
    field :augur,          :boolean #TODO RENAME
    field :augured_at      :date    #TODO NEW

    field :regex,          :string
    field :rss_feed,       :string
    field :subgroup,       :string
    field :quality,        :string

    # Time Data
    many_to_many :season, Season,
      join_through: "series_seasons",
      default: []

    field :airing,     :bool #TODO NEW
    field :airing_at,  :date #TODO NEW

    # TODO Rename
    #field :started_airing_date,  :date
    #field :finished_airing_date, :date
    # ->
    # to this
    field :start_date, :date
    field :end_date,   :date

    timestamps()
  end

end

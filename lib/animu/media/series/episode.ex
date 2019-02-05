defmodule Animu.Media.Series.Episode do
  use Ecto.Schema

  alias Animu.Media.{Series, Video}

  @derive {Poison.Encoder, except: [:__meta__]}
  schema "episodes" do
    field :title,         :string
    field :synopsis,      :string
    field :number,        :float

    field :airdate,       :date
    field :augured_at,    :date #TODO new

    field :kitsu_id,      :string

    field :season_number, :integer #TODO Remove
    field :thumbnail,     {:map, :string} #TODO Remove

    belongs_to :series, Series
    embeds_one :video, Video, on_replace: :delete

    field :video_path, :string, virtual: true

    timestamps()
  end

end

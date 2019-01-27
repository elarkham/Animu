defmodule Animu.Media.Episode do
  use Ecto.Schema

  alias Animu.Media.{Series, Video}

  #@derive {Poison.Encoder, except: [:__meta__]}
  schema "episodes" do
    field :title,         :string
    field :synopsis,      :string
    field :thumbnail,     {:map, :string}
    field :kitsu_id,      :string

    field :number,        :float
    field :season_number, :integer
    field :airdate,       :date

    #field :video_updated, :date
    #field :augur_updated, :date

    belongs_to :series, Series
    embeds_one :video, Video, on_replace: :delete

    field :video_path, :string, virtual: true

    timestamps()
  end

end

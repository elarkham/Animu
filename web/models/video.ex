defmodule Animu.Video do
  use Animu.Web, :model

  @derive {Poison.Encoder, only: [:id, :filename]}

  schema "videos" do
    field :filename, :string
    field :thumbnail, :string
    field :path, :string

    field :stream_count, :integer
    field :format_name, :string
    field :duration, :float
    field :quality, :string
    field :size, :integer

    belongs_to :episode,      Animu.Episode
    has_many   :video_codec,  Animu.VideoCodec
    has_many   :audio_codecs, Animu.AudioCodec
    has_many   :subtitles,    Animu.Subtitle

    timestamps
  end

  @required_fields ~w(filename)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `struct` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
  end
end

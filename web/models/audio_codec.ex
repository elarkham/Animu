defmodule Animu.AudioCodec do
  use Animu.Web, :model

  @derive {Poison.Encoder, only: [:id, :stream_index]}

  schema "audiocodec" do
    field :stream_index, :integer
    field :codec_name, :string
    field :bitrate, :integer
    field :profile, :string
    field :language, :string
    field :disposition, :string
    field :channels, :integer
    field :channel_layout, :string

    belongs_to :video, Animu.Video

    timestamps
  end

  @required_fields ~w(stream_index video)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

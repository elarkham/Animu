defmodule Animu.Subtitle do
  use Animu.Web, :model

  @derive {Poison.Encoder, only: [:id, :path]}

  schema "subtitle" do
    field :type, :string
    field :path, :string
    field :fonts, {:array, :string}
    field :audio_stream_index, :integer
    belongs_to :video, Animu.Video

    timestamps
  end

  @required_fields ~w(path video)
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

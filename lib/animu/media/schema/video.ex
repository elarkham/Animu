defmodule Animu.Media.Video do
  use Ecto.Schema

  import Ecto.Changeset
  alias __MODULE__, as: Video

  embedded_schema do
    field :filename,    :string
    field :dir,         :string, default: "videos"
    field :extension,   :string

    field :format,      :string
    field :format_name, :string

    field :duration,    :decimal
    field :start_time,  :decimal
    field :size,        :integer

    field :bit_rate,    :integer
    field :probe_score, :integer

    field :thumbnail,   {:map, :string}

    embeds_one :video_track, VideoTrack do
      field :index,           :integer
      field :codec_name,      :string

      field :coded_width,     :integer
      field :coded_height,    :integer
      field :width,           :integer
      field :height,          :integer

      field :pix_fmt,         :string
      field :bit_rate,        :integer
      field :profile,         :string

      field :nb_frames,       :integer
      field :avg_frame_rate,  :string

      field :start_time,      :decimal
      field :duration,        :decimal

      field :bits_per_raw_sample,  :integer
      field :display_aspect_ratio, :string
    end

    embeds_one :audio_track, AudioTrack do
      field :index,           :integer
      field :codec_name,      :string
      field :language,        :string

      field :bit_rate,        :integer
      field :bits_per_sample, :integer
      field :max_bit_rate,    :integer

      field :sample_rate,     :integer
      field :sample_fmt,      :string
      field :profile,         :string
      field :nb_frames,       :integer

      field :channel_layout,  :string
      field :channels,        :integer

      field :start_time,      :decimal
      field :duration,        :decimal
    end

    embeds_one :subtitles, Subtitles do
      field :type,        :string, default: "ass"

      field :filename,    :string
      field :dir,         :string

      field :fonts,       {:array, :string}
      field :font_dir,    :string
    end
  end

  @doc """
  Returns `%Ecto.Changeset{}` for tracking Video changes
  """
  def changeset(%Video{} = video, attrs) do
    video
    |> cast(attrs, all_fields_except([:video_track, :audio_track, :subtitles]))
    |> validate_required([:filename])
    |> cast_embed(:video_track, with: &video_track_changeset/2)
    |> cast_embed(:audio_track, with: &audio_track_changeset/2)
    |> cast_embed(:subtitles,   with: &subtitles_changeset/2)
  end

  def change(%Video{} = video) do
    changeset(video, %{})
  end

  defp all_fields_except(list) do
    Enum.reduce(list, Video.__schema__(:fields), fn i, acc ->
      List.delete(acc, i)
    end)
  end

  defp video_track_changeset(%Video.VideoTrack{} = video_codec, attrs) do
    video_codec
    |> cast(attrs, Video.VideoTrack.__schema__(:fields))
  end

  defp audio_track_changeset(%Video.AudioTrack{} = audio_codec, attrs) do
    audio_codec
    |> cast(attrs, Video.AudioTrack.__schema__(:fields))
  end

  defp subtitles_changeset(%Video.Subtitles{} = subtitles, attrs) do
    subtitles
    |> cast(attrs, Video.Subtitles.__schema__(:fields))
  end
end

defmodule Animu.Media.Anime.Video do
  @moduledoc """
  Stores video metadata from ffprobe plus the location of the file.
  Should be immutable after initial generation.
  """
  use Animu.Ecto.Schema
  alias __MODULE__

  @derive Jason.Encoder
  embedded_schema do
    field :filename,    :string
    field :dir,         :string, default: "videos"
    field :extension,   :string
    field :path,        :string

    field :format,      :string
    field :format_name, :string

    field :duration,    :decimal
    field :start_time,  :decimal
    field :size,        :integer

    field :bit_rate,    :integer
    field :probe_score, :integer

    field :original,    :string

    field :thumbnail,   {:map, :string}

    embeds_one :video_track, VideoTrack, on_replace: :delete do
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

    embeds_one :audio_track, AudioTrack, on_replace: :delete do
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

    embeds_one :subtitles, Subtitles, on_replace: :delete do
      field :type,        :string, default: "ass"

      field :filename,    :string
      field :dir,         :string

      field :fonts,       {:array, :string}
      field :font_dir,    :string
    end
  end

  require Protocol
  Protocol.derive(Jason.Encoder, Video.VideoTrack)
  Protocol.derive(Jason.Encoder, Video.AudioTrack)
  Protocol.derive(Jason.Encoder, Video.Subtitles)

  def changeset(%Video{} = video, attrs) do
    video
    |> cast(attrs, all_fields(Video, except: [:video_track, :audio_track, :subtitles]))
    |> validate_required([:filename])
    |> cast_embed(:video_track, with: &video_track_changeset/2)
    |> cast_embed(:audio_track, with: &audio_track_changeset/2)
    |> cast_embed(:subtitles,   with: &subtitles_changeset/2)
    |> update_path
  end

  def change(%Video{} = video) do
    changeset(video, %{})
  end

  def video_track_changeset(%Video.VideoTrack{} = video_codec, attrs) do
    video_codec
    |> cast(attrs, all_fields(Video.VideoTrack))
  end

  def audio_track_changeset(%Video.AudioTrack{} = audio_codec, attrs) do
    audio_codec
    |> cast(attrs, all_fields(Video.AudioTrack))
  end

  def subtitles_changeset(%Video.Subtitles{} = subtitles, attrs) do
    subtitles
    |> cast(attrs, all_fields(Video.Subtitles))
  end

  def update_path(ch) do
    case ch.valid? do
      true ->
        dir  = get_field(ch, :dir)
        name = get_field(ch, :filename)
        path = Path.join(dir, name)
        update_change(ch, :path, path)
      _ -> ch
    end
  end

  defdelegate new(video_path, anime_dir), to: Video.Invoke
end

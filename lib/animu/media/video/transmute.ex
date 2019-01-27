defmodule Animu.Media.Video.Transmute do
  import Ecto.Changeset

  alias Animu.Media.Video
  alias Video.{VideoTrack, AudioTrack, Subtitles, Bag}

  def transmute(%Bag{} = bag, :video) do
    video_track =
      %VideoTrack{}
      |> Video.video_track_changeset(bag.video_track)
      |> apply_changes

    audio_track =
      %AudioTrack{}
      |> Video.audio_track_changeset(bag.audio_track)
      |> apply_changes

    subtitles =
      transmute(bag, :subtitles)

    original =
      Path.join(bag.input.dir, bag.input.filename)

    %Video{}
      |> Video.changeset(bag.output.probe_data["format"])
      |> apply_changes
      |> Map.put(:filename, bag.output.filename)
      |> Map.put(:dir, bag.output.dir)
      |> Map.put(:format, bag.output.format)
      |> Map.put(:extension, bag.output.extension)
      |> Map.put(:original, original)
      |> Map.put(:video_track, video_track)
      |> Map.put(:audio_track, audio_track)
      |> Map.put(:subtitles, subtitles)
      |> Map.put(:thumbnail, bag.thumb.data)
  end

  def transmute(%Bag{subtitles: nil}, :subtitles), do: nil
  def transmute(%Bag{} = bag, :subtitles) do
    %Subtitles{
      type: "ass",
      dir: bag.subtitles.dir,
      filename: bag.subtitles.filename,
      fonts: bag.font.filenames,
      font_dir: bag.font.dir,
    }
  end
end

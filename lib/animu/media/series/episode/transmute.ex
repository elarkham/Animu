defmodule Animu.Media.Series.Episode.Transmute do
  import Ecto.Changeset

  alias Animu.Media.Series.Episode
  alias Animu.Media.Video
  alias Animu.Schema
  alias Ecto.Changeset

  def transmute(%Changeset{} = changeset, :episode) do
    %Episode{} = apply_changes(changeset)
  end

  def transmute(%Episode{} = episode, %Video{} = video) do
    Map.put(episode, :video, video)
  end

  def transmute(%Episode{} = episode, %Changeset{} = changeset) do
    new_changeset =
      cast(changeset.data, Schema.to_params(episode),
        Schema.all_fields(Episode, except: [:video]) ++ [:video_path])

    merge(changeset, new_changeset)
  end
end

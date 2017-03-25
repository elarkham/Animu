defmodule Animu.Media.Episode.Invoke do
  import Ecto.Changeset
  import Animu.Media.Episode.Transmute

  alias Ecto.Changeset
  alias Animu.Media.Video
  alias Animu.Media

 def conjure_video(changeset = %Changeset{valid?: false}), do: changeset
 def conjure_video(changeset = %Changeset{changes: %{video_path: _}}) do
    series =
      changeset
      |> Changeset.get_field(:series_id)
      |> Media.get_series!()

    conjure_video(changeset, series.directory)
  end
  def conjure_video(%Changeset{} = changeset), do: changeset

  def conjure_video(changeset = %Changeset{valid?: false}), do: changeset
  def conjure_video(
    changeset = %Changeset{changes: %{video_path: input_path}}, series_dir) do

    case Video.Invoke.new(input_path, series_dir) do
      {:ok, video} ->
        put_embed(changeset, :video, video)

      {:error, reason} ->
        add_error(changeset, :video_path, reason)

      _ ->
        {:error, "Unexpected Error When Conjuring Video"}
    end
  end
  def conjure_video(%Changeset{} = changeset, _), do: changeset
end

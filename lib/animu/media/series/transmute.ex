defmodule Animu.Media.Series.Transmute do

  import Ecto.Changeset
  import Animu.Media.Episode.Invoke

  alias Ecto.Changeset
  alias Animu.Media.Series.Bag
  alias Animu.Media.{Series, Episode, Video}
  alias Animu.Schema

  def transmute(%Changeset{} = changeset, :series) do
    %Series{} = apply_changes(changeset)
  end

  def transmute(%Series{} = series, :bag) do
    Bag.new(series)
  end

  def transmute(%Bag{} = bag, :series) do
    %Series{}
    |> struct(nil_to_map(bag.kitsu_data))
    |> Map.put(:poster_image, bag.poster_image)
    |> Map.put(:cover_image, bag.cover_image)
    |> Map.put(:episodes, bag.episodes)
    |> Map.put(:episode_count, bag.ep_count)
    |> Map.put(:directory, bag.dir)
    |> Map.put(:regex, transmute_regex(bag.regex, :string))
  end

  def transmute(%Series{} = series, %Changeset{} = changeset) do
    episodes =
      transmute_episodes(series.episodes, series.directory)

    changeset.data
      |> cast(Map.from_struct(series), Schema.all_fields(Series))
      |> merge(changeset)
      |> put_assoc(:episodes, episodes)
  end

  def transmute_regex(nil, :string), do: nil
  def transmute_regex(regex, :string) do
    case Regex.regex?(regex) do
      true  -> Regex.source(regex)
      false -> regex
    end
  end

  def transmute_episodes(episodes, series_dir) do
    Task.async_stream(episodes, fn episode ->
      episode
      |> Map.from_struct()
      |> episode_changeset(series_dir)
    end, timeout: 1000 * 60 * 60)
    |> Enum.to_list()
    |> Enum.map(fn {:ok, ep} -> ep end)
  end

  defp episode_changeset(attrs, series_dir) do
    %Episode{}
    |> cast(attrs, Schema.all_fields(Episode, except: [:video]) ++ [:video_path])
    |> validate_required([:title, :number])
    |> conjure_video_if_nil(series_dir)
    |> delete_change(:video_path)
  end

  defp conjure_video_if_nil(changeset, series_dir) do
    case changeset do
      %Changeset{params: %{"video" => nil}} ->
        conjure_video(changeset, series_dir)

      %Changeset{params: %{"video" => video}} ->
        put_embed(changeset, :video, video)

       _ ->
        changeset
    end
  end

  defp nil_to_map(value) do
    case value do
      nil -> %{}
      _ -> value
    end
  end
end

defmodule Animu.Media.Anime.Transmute do
  """
  import Ecto.Changeset
  import Animu.Media.Episode.Invoke

  alias Ecto.Changeset
  alias Animu.Media.Anime.Bag
  alias Animu.Media.{Anime, Episode}
  alias Animu.Schema

  def transmute(%Changeset{} = changeset, :anime) do
    %Anime{} = apply_changes(changeset)
  end

  def transmute(%Anime{} = anime, :bag) do
    Bag.new(anime)
  end

  def transmute(%Bag{} = bag, :anime) do
    %Anime{}
    |> struct(nil_to_map(bag.kitsu_data))
    |> Map.put(:poster_image, bag.poster_image)
    |> Map.put(:cover_image, bag.cover_image)
    |> Map.put(:episodes, bag.episodes)
    |> Map.put(:episode_count, bag.ep_count)
    |> Map.put(:directory, bag.dir)
    |> Map.put(:regex, transmute_regex(bag.regex, :string))
  end

  def transmute(%Anime{} = anime, %Changeset{} = changeset) do
    changeset.data
      |> cast(Schema.to_params(anime), Schema.all_fields(Anime))
  end
  def transmute(%Anime{} = anime, %Changeset{} = changeset, :merge) do
    episodes =
      transmute_episodes(anime.episodes, anime.directory)

    IO.puts "Episodes Transmuted"
    changeset.data
      |> cast(Schema.to_params(anime), Schema.all_fields(Anime))
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

  def transmute_episodes(episodes, anime_dir) do
    Task.async_stream(episodes, fn episode ->
      IO.puts "Conjuring Video"
      episode
      |> Map.from_struct()
      |> episode_changeset(anime_dir)
    end, timeout: 1000 * 60 * 60)
    |> Enum.to_list()
    |> Enum.map(fn {:ok, ep} -> ep end)
  end

  defp episode_changeset(attrs, anime_dir) do
    %Episode{}
    |> cast(attrs, Schema.all_fields(Episode, except: [:video]) ++ [:video_path])
    |> validate_required([:title, :number])
    |> conjure_video_if_nil(anime_dir)
    |> delete_change(:video_path)
  end

  defp conjure_video_if_nil(changeset, anime_dir) do
    #case changeset do
    #  %Changeset{params: %{"video" => nil}} ->
    #    conjure_video(changeset, anime_dir)

    #  %Changeset{params: %{"video" => video}} ->
    #    put_embed(changeset, :video, video)

    #   _ ->
    #    changeset
    #end
    conjure_video(changeset, anime_dir)
  end

  defp nil_to_map(value) do
    case value do
      nil -> %{}
      _ -> value
    end
  end
  """
end

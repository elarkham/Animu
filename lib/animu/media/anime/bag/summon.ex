defmodule Animu.Media.Anime.Bag.Summon do
  @moduledoc """
  Fills field values using external APIs such as Kitsu.io
  """
  import Ecto.Changeset
  import Animu.Util.Schema

  alias Animu.Media.Anime
  alias Animu.Media.Anime.{Bag, Episode, Genre}
  alias Animu.Media.Upload.Image
  alias Animu.Media.Kitsu

  alias __MODULE__, as: Summon
  defstruct [
    :src,
    :force,
    :data,
    :genres,
    :episodes
  ]

  ## Compilation
  def compile(%Bag{} = bag, summons) do
    bag =
      bag
      |> Map.put(:summons, summons)
      |> compile_genres(summons)

    {:ok, bag}
  end

  # Compile -> Genres
  def compile_genres(%Bag{} = bag, summons) do
    todo =
      summons
      |> Enum.map(&(&1.genres))
      |> Enum.concat
      |> Enum.dedup_by(&(&1.slug))
      |> genre_todo

    Map.put(bag, :todo, [todo | bag.todo])
  end
  defp genre_todo(genres) do
    todo = fn ch ->
      genres = Genre.insert_or_get_all(genres)
      put_change(ch, :genres, genres)
    end
  end

  ## Gather from sources
  def gather(%Bag{} = bag, params) do
    Enum.reduce_while(params, {:ok, []}, fn source, acc ->
      name = source.source
      {:ok, acc} = acc
      case Summon.summon(source, bag) do
          {:ok, data} -> {:cont, {:ok, acc ++ [data]}}
        {:error, msg} -> {:halt, {:error, %{name => msg}}}
      end
    end)
  end

  ## Source: Kitsu
  def summon(%{source: "kitsu"} = src, %Bag{} = bag) do
    with         :ok  <- validate_kitsu_id(bag),
         {:ok, kitsu} <- request_kitsu_data(bag),
         {:ok, kitsu} <- request_kitsu_episode_data(bag, kitsu),
         {:ok, kitsu} <- request_kitsu_genre_data(bag, kitsu),
         {:ok, kitsu} <- request_kitsu_mapping_data(bag, kitsu),
               anime  <- format_kitsu_to_anime(kitsu),
               anime  <- trim_anime(anime, src) do

      episodes = anime[:episodes]
      genres   = anime[:genres]

      data = Map.drop(anime, [:episodes, :genres])

      summon =
        %Summon{
          src: "kitsu",
          data: data,
          genres: genres,
          episodes: episodes,
          force: src.force,
        }

      {:ok, summon}
    else
      {:error, msg} -> {:error, msg}
      error ->
        {:error, "Unexpected Error During Kitsu Summon: #{inspect error}"}
    end
  end

  def validate_kitsu_id(%Bag{} = bag) do
    case bag.data do
      %{kitsu_id: nil} ->
        {:error, "Kitsu Id Is Required For Summon"}
      %{kitsu_id: _} -> :ok
    end
  end

  defp request_kitsu_data(%Bag{data: %{kitsu_id: id}}) do
    Kitsu.request("anime", id)
  end

  defp request_kitsu_episode_data(%Bag{data: %{kitsu_id: id}}, data) do
    case Kitsu.request_relationship("anime", "episodes", id) do
      {:ok, episodes} ->
        episodes = Enum.map(episodes, &format_kitsu_to_episode/1)
        {:ok, Map.put(data, "episodes", episodes)}
      {:error, msg} ->
        {:error, msg}
    end
  end

  defp request_kitsu_genre_data(%Bag{data: %{kitsu_id: id}}, data) do
    case Kitsu.request_relationship("anime", "categories", id) do
      {:ok, genres} ->
        genres = Enum.map(genres, &format_kitsu_to_genre/1)
        {:ok, Map.put(data, "genres", genres)}
      {:error, msg} ->
        {:error, msg}
    end
  end

  defp request_kitsu_mapping_data(%Bag{data: %{kitsu_id: id}}, data) do
    case Kitsu.request_relationship("anime", "mappings", id) do
      {:ok, mappings} ->
        mappings =
          mappings
          |> Enum.map(&format_kitsu_mappings/1)
          |> Enum.reduce(&Map.merge/2)
        {:ok, Map.merge(data, mappings)}
      {:error, msg} ->
        {:error, msg}
    end
  end

  defp format_kitsu_mappings(map) do
    id = map["externalId"]
    case map["externalSite"] do
                  "anidb" -> %{"anidb_id" => id}
      "myanimelist/anime" -> %{"mal_id"   => id}
                "thetvdb" -> %{"tvdb_id"  => id}
      _ -> %{}
    end
  end

  defp format_kitsu_image(nil), do: nil
  defp format_kitsu_image(%{"original" => orig}), do: orig

  defp format_kitsu_to_anime(kitsu) do
    kitsu =
      %{name: kitsu["canonicalTitle"],
        titles: kitsu["titles"],
        synopsis: kitsu["synopsis"],
        slug: kitsu["slug"],

        poster_image: format_kitsu_image(kitsu["posterImage"]),
        cover_image: format_kitsu_image(kitsu["coverImage"]),

        age_rating: kitsu["ageRating"],
        age_guide: kitsu["ageRatingGuide"],
        nsfw: kitsu["nsfw"],

        episode_count: kitsu["episodeCount"],
        episode_length: kitsu["episodeLength"],

        kitsu_rating: kitsu["averageRating"],

        kitsu_id: kitsu["id"],
        anidb_id: kitsu["anidb_id"],
        mal_id: kitsu["mal_id"],
        tvdb_id: kitsu["tvdb_id"],

        status: kitsu["status"],
        start_date: kitsu["startDate"],
        end_date: kitsu["endDate"],

        episodes: kitsu["episodes"],
        genres: kitsu["genres"],
      }
      |> Map.put_new(:episodes, [])
      |> Map.put_new(:genres,   [])

    %Anime{}
    |> cast(kitsu, all_fields(Anime))
    |> apply_changes
    |> to_map
    |> Map.put(:genres, kitsu[:genres])
    |> Map.put(:episodes, kitsu[:episodes])
    |> Map.delete(:season)
    |> Map.delete(:franchise)
  end

  def format_kitsu_to_episode(kitsu) do
    kitsu =
      %{name: kitsu["canonicalTitle"],
        synopsis: kitsu["synopsis"],

        number: kitsu["number"],
        rel_number: kitsu["relativeNumber"],
        airdate: kitsu["airdate"],

        kitsu_id: kitsu["id"],
       }

    %Episode{}
    |> cast(kitsu, all_fields(Episode, except: [:video]))
    |> apply_changes
    |> to_map
    |> Map.delete(:anime)
  end

  def format_kitsu_to_genre(kitsu) do
    kitsu =
      %{name: kitsu["title"],
        slug: kitsu["slug"],
        nsfw: kitsu["nsfw"],

        description: kitsu["description"],
        poster: format_kitsu_image(kitsu["image"]),

        kitsu_id: kitsu["id"],
      }

    %Genre{}
    |> cast(kitsu, all_fields(Genre))
    |> apply_changes
    |> to_map
    |> Map.delete(:anime)
    |> Map.delete(:poster) #TODO handle this somehow
  end

  # Trimming
  defp trim_nil(data) do
    Enum.reduce(data, %{}, fn {k, v}, acc ->
      case v do
        nil -> acc
        v -> Map.put(acc, k, v)
      end
    end)
  end

  defp trim_anime(anime, %{except: fields}) when length(fields) > 0 do
    fields = Enum.map(fields, &String.to_existing_atom/1)

    anime
    |> Map.drop(fields)
  end
  defp trim_anime(anime, %{only: fields}) when length(fields) > 0 do
    fields = Enum.map(fields, &String.to_existing_atom/1)

    anime
    |> Map.take(fields)
  end
  defp trim_anime(anime, _source), do: anime

end

defmodule Animu.Media.Series.Bag.Summon do
  import Ecto.Changeset

  alias Animu.Media.Series.Bag
  alias Animu.Media.Upload.Image
  alias Animu.Media.Kitsu

  alias __MODULE__, as: Summon
  defstruct
    src: nil,
    force: false,
    data: %{}

  # Merge
  # TODO handle episode merge
  defp merge_summons(series, summons) do
    Enum.reduce(summons, series, fn summon, series ->
      Map.merge(series, summon)
    end)
  end

  # Trimming
  defp trim_nil(data) do
    Enum.reduce(series, %{}, fn {k, v}, acc ->
      case v do
        nil -> acc
        x -> %{acc | ^k => v}
    end)
  end

  defp trim_series(series, %{except: fields}) when is_length(fields) > 0, do
    fields = Enum.map(fields, &String.to_existing_atom/1)

    series
    |> Map.drop(fields)
    |> trim_series(%{})
  end
  defp trim_series(series, %{only: fields}) when is_length(fields) > 0, do
    fields = Enum.map(fields, &String.to_existing_atom/1)

    series
    |> Map.take(fields)
    |> trim_series(%{})
  end
  defp trim_series(series, _source) do
    series
    |> trim_nil
    |> trim_episodes
  end

  defp trim_episodes(series = %{episodes: nil}), do: series
  defp trim_episodes(series = %{episodes: eps}) do
    eps = Enum.map(eps, &trim_nil/1)
    %{series | episodes: eps}
  end


  ## Source: Kitsu
  def summon(%{name: "kitsu"} = src, %Bag{} = bag) do
    with         :ok  <- validate_kitsu_id(bag)
         {:ok, kitsu} <- request_kitsu_data(bag),
         {:ok, kitsu} <- request_kitsu_episode_data(bag, kitsu),
         {:ok, kitsu} <- request_kitsu_genre_data(bag, kitsu) do
              series  <- format_kitsu_to_series(kitsu)
              series  <- trim_series(series, src)

      summon =
        %Summon{src: "kitsu", force: src.force, data: series}

      {:ok, summon}
    else
      {:error, msg} -> {:error, msg}
      error -> {:error, "Unexpected Error During Kitsu Summon: #{error}"}
    end
  end

  def validate_kitsu_id(%Bag{} = bag) do
    case bag do
      %{kitsu_id: nil} ->
        {:error, "Kitsu Id Is Required For Summon"}
      %{kitsu_id: _} ->
        {:ok, bag}
    end
  end

  defp request_kitsu_data(%Bag{data: %{kitsu_id: id}} = bag) do
    Kitsu.request("anime", id)
  end

  defp request_kitsu_episode_data(%Bag{data: %{kitsu_id: id}} = bag, data) do
    case Kitsu.request_relationship("anime", "episodes", id) do
      {:ok, episodes} ->
        episodes = Enum.map(episodes, &format_kitsu_to_episode/1)
        {:ok, Map.put(data, "episodes", episodes)}
      {:error, msg} ->
        {:error, msg}
    end
  end

  defp request_kitsu_genre_data(%Bag{data: %{kitsu_id: id}} = bag, data) do
    case Kitsu.request_relationship("anime", "categories", id) do
      {:ok, genres} ->
        genres = Enum.map(genres, &format_kitsu_to_genre/1)
        {:ok, Map.put(data, "genres", genres)}
      {:error, msg} ->
        {:error, msg}
    end
  end

  defp request_kitsu_mapping_data(%Bag{data: %{kitsu_id: id}} = bag, data) do
    case Kitsu.request_relationship("anime", "mappings", id) do
      {:ok, mappings} ->
        mappings =
          mappings
          |> Enum.map(format_kitsu_mappings/1)
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

  defp format_kitsu_to_series(kitsu) do
    kitsu =
      %{canon_title: kitsu["canonicalTitle"],
        titles: kitsu["titles"],
        synopsis: kitsu["synopsis"],
        slug: kitsu["slug"],

        poster_image: format_kitsu_image(kitsu["posterImage"]),
        cover_image: format_kitsu_image(kitsu["coverImage"]),

        age_rating: kitsu["ageRating"],
        age_rating_guide: kitsu["ageRatingGuide"],
        nsfw: kitsu["nsfw"],

        episode_count: kitsu["episodeCount"],
        episode_length: kitsu["episodeLength"],

        kitsu_rating: kitsu["averageRating"],

        kitsu_id: kitsu["id"],
        anidb_id: kitsu["anidb_id"],
        mal_id: kitsu["mal_id"],
        tvdb_id: kitsu["tvdb_id"],

        status: kitsu["status"]
        start_date: kitsu["startDate"],
        end_date: kitsu["endDate"],

        episodes: kitsu["episodes"],
        genres: kitsu["genres"],
      }

    %Series{}
    |> cast(kitsu, all_fields(Series))
    |> apply_changes
    |> Map.from_struct
  end

  def format_kitsu_to_episode(kitsu) do
    kitsu =
      %{title: kitsu["canonicalTitle"],
        synopsis: kitsu["synopsis"],

        number: kitsu["number"],
        season_number: kitsu["seasonNumber"],
        airdate: kitsu["airdate"],

        kitsu_id: kitsu["id"],
       }

    %Episode{}
    |> cast(kitsu, all_fields(Episode))
    |> apply_changes
    |> Map.from_struct
  end

  def format_kitsu_to_genre(kitsu) do
    kitsu =
      %{title: kitsu["title"],
        slug: kitsu["slug"],
        nsfw: kitsu["nsfw"],

        description: kitsu["description"],

        poster: format_kitsu_image(kitsu["image"]),
      }

    %Genre{}
    |> cast(kitsu, all_fields(Genre))
    |> apply_changes
    |> Map.from_struct
  end
end

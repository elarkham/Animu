defmodule Animu.Media.Kitsu do

  alias HTTPoison.Response

  @url "https://kitsu.io/api/edge/"

  def request(type, id) do
    url = @url <> type <> "/" <> to_string(id)
    headers = ["Accept": "application/vnd.api+json"]
    options = [follow_redirect: true]

    with {:ok, %Response{body: body}} <- HTTPoison.get(url, headers, options),
         {:ok, body} <- Poison.Parser.parse(body) do
      {:ok, Map.put(body["data"]["attributes"], "id", id)}
    else
      reason ->
        IO.inspect(reason)
        {:error, "HTTP Request For Kitsu Data Failed, Type: #{type}, Id: #{id}"}
    end
  end

  def request_relationship(type, relation, id) do
    url = @url <> type <> "/" <> to_string(id) <> "/relationships/" <> relation
    headers = ["Accept": "application/vnd.api+json"]
    options = [follow_redirect: true]

    with {:ok, %Response{body: body}} <- HTTPoison.get(url, headers, options),
         {:ok, %{"data" => relations}} <- Poison.Parser.parse(body),
         {:ok, relations} <- request_each_relationship(relations) do
      {:ok, relations}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "HTTP Request For Kitsu Data Failed"}
    end
  end

  defp request_each_relationship(relations) do
    relations =
      Enum.reduce_while(relations, [], fn x, acc ->
        #IO.inspect x
        #:timer.sleep(1000)
        case request(x["type"], x["id"]) do
          {:ok, rel} -> {:cont, acc ++ [rel]}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)

    case relations do
      {:error, reason} -> {:error, reason}
      _ -> {:ok, relations}
    end
  end

  def request_related(type, related, id) do
    url = @url <> type <> "/" <> to_string(id) <> "/" <> related
    headers = ["Accept": "application/vnd.api+json"]
    options = [follow_redirect: true]

    with {:ok, %Response{body: body}} <- HTTPoison.get(url, headers, options),
         {:ok, %{"data" => data}} <- Poison.Parser.parse(body),
         data <- format_related(data) do
      {:ok, data}
    else
      _ -> {:error, "HTTP Request For Kitsu Data Failed"}
    end
  end

  defp format_related(data) do
    Enum.map(data, fn rel ->
       Map.put(rel["attributes"], "id", rel["id"])
    end)
  end

  defp convert_date(date) do
    case date do
      nil -> nil
      _ -> Date.from_iso8601!(date)
    end
  end

  defp convert_map(map) do
    case map do
      nil -> %{}
      _ -> map
    end
  end

  defp convert_float(num) when is_integer(num) do
    num/1
  end

  defp convert_float(num) do
    case Float.parse(num) do
      :error -> nil
      {float, _} -> float
    end
  end

  def format_to_franchise(kitsu_franchise) do
    #TODO Create Franchise Formater
    kitsu_franchise
  end

  def format_to_series(kitsu_series) do
    %{canon_title: kitsu_series["canonicalTitle"],
      titles: kitsu_series["titles"],
      synopsis: kitsu_series["synopsis"],
      slug: kitsu_series["slug"],

      cover_urls: convert_map(kitsu_series["coverImage"]),
      poster_urls: convert_map(kitsu_series["posterImage"]),

      age_rating: kitsu_series["ageRating"],
      nsfw: kitsu_series["nsfw"],

      episode_count: kitsu_series["episodeCount"],
      episode_length: kitsu_series["episodeLength"],

      kitsu_rating: kitsu_series["averageRating"],
      kitsu_id: kitsu_series["id"],

      started_airing_date: convert_date(kitsu_series["startDate"]),
      finished_airing_date: convert_date(kitsu_series["endDate"]),
    }
  end

  def format_to_episode(kitsu_episode) do
    %{ title: kitsu_episode["canonicalTitle"],
       synopsis: kitsu_episode["synopsis"],

       number: convert_float(kitsu_episode["number"]),
       season_number: kitsu_episode["seasonNumber"],
       airdate: kitsu_episode["airdate"],

       kitsu_id: kitsu_episode["id"],
     }
  end

end

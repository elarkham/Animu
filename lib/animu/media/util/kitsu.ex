defmodule Animu.Media.Kitsu do
  @moduledoc """
  Interface for Kitsu's web API
  """
  alias HTTPoison.Response
  alias Animu.Media.{Series, Episode}
  require Logger

  @url "https://kitsu.io/api/edge/"

  defp handle_error(type, id, error) do
    msg = "http request for kitsu data failed, type: #{type}, id: #{id}"
    Logger.error(msg <> ", reason: #{reason}")
    {:error, msg}
  end

  def request_collection(type, ids, offset \\ 0) when is_list(ids) do
    fields = Enum.join(ids, ",")
    querystring = URI.encode_query(
      %{"filter[id]" => fields,
        "page[limit]" => 20,
        "page[offset]" => offset})
    url = @url <> type <> "?" <> querystring
    headers = ["Accept": "application/vnd.api+json"]
    options = [follow_redirect: true]

    with {:ok, %Response{body: body}} <- HTTPoison.get(url, headers, options),
         {:ok, body} <- Poison.Parser.parse(body) do

      data = Map.new(body["data"], fn data ->
        {data["id"], Map.put(data["attributes"], "id", data["id"])}
      end)

      if offset >= Enum.count(ids) do
        {:ok, data}
      else
        {:ok, next} = request_collection(type, ids, offset + 20)
        {:ok, Map.merge(data, next)}
      end
    else
      error -> handle_error(type, fields, error)
    end
  end

  def request(type, id) do
    url = @url <> type <> "/" <> to_string(id)
    headers = ["Accept": "application/vnd.api+json"]
    options = [follow_redirect: true]

    with {:ok, %Response{body: body}} <- HTTPoison.get(url, headers, options),
         {:ok, body} <- Poison.Parser.parse(body) do

      {:ok, Map.put(body["data"]["attributes"], "id", id)}
    else
      error -> handle_error(type, id, error)
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
      error -> handle_error(type, id, error)
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
      error -> handle_error(type, id, error)
    end
  end

  defp format_related(data) do
    Enum.map(data, fn rel ->
       Map.put(rel["attributes"], "id", rel["id"])
    end)
  end

end

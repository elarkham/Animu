defmodule Animu.SeriesPopulator do
  import Animu.ModelHelper

  alias Animu.Series
  alias HTTPoison.Response

  @url "https://kitsu.io/api/edge/"

	# Image Paths
	@cover_path "/images/cover"
  @poster_path "/images/poster"
  @gallery_path "/images/gallery"

  def populate(series) do
    series = Series.scrub_params(series)
    case series do
      %{kitsu_id: nil} -> series
      %{kitsu_id: _} -> _populate(series)
      :else -> series
    end
  end

  def _populate(series) do
    request("anime", series.kitsu_id)
    |> format_to_series
    |> soft_merge(series)
    |> get_images
  end


  defp request(type, id) do
    url = @url <> type <> "/" <> id
    headers = ["Accept": "application/vnd.api+json"]
    options = [follow_redirect: true]

    {:ok, %Response{body: body}} = HTTPoison.get(url, headers, options)
    body = Poison.decode!(body)
    Map.put(body["data"]["attributes"], "id", id)
  end

  defp format_to_series(kitsu_series) do
    %Series{
      canon_title: kitsu_series["canonicalTitle"],
      titles: kitsu_series["titles"],
      synopsis: kitsu_series["synopsis"],
      slug: kitsu_series["slug"],

      cover_image: kitsu_series["coverImage"],
      poster_image: kitsu_series["posterImage"],
      gallery: kitsu_series["gallery"],

      age_rating: kitsu_series["ageRating"],
      nsfw: kitsu_series["nsfw"],

      episode_count: kitsu_series["episodeCount"],
      episode_length: kitsu_series["episodeLength"],

      kitsu_rating: kitsu_series["averageRating"],
      kitsu_id: kitsu_series["id"],

      started_airing_date: Date.from_iso8601!(kitsu_series["startDate"]),
      finished_airing_date: Date.from_iso8601!(kitsu_series["endDate"]),
    }
  end

  def get_images(series = %Series{directory: nil}), do: series
  def get_images(series) do
		path = series.directory <> @cover_path
		cover_image = get_map_images(series.cover_image, path)

    path = series.directory <> @poster_path
		poster_image = get_map_images(series.poster_image, path)

		path = series.directory <> @gallery_path
		gallery = get_map_images(series.gallery, path)

    changes = %{gallery: gallery, cover_image: cover_image, poster_image: poster_image}
		Map.merge(series, changes)
  end

  defp get_map_images(nil, _), do: nil
  defp get_map_images(map, path) do
    Map.new(map, fn {k, v} ->
      filename =  "/" <> k <> ".jpg"
		 	v = get_image(v, path, filename)
		 	{k, v}
    end)
  end

  defp get_image(nil, _, _), do: nil
	defp get_image(url, path, filename) do
   	{:ok, %Response{body: body}} = HTTPoison.get(url)
  	full_path = Application.get_env(:animu, :file_root) <> path
    if !(File.dir?(path)), do: File.mkdir_p!(full_path)
   	File.write!(full_path <> filename, body)
		path <> filename
	end

end

defmodule Animu.SeriesPopulator do
  import Animu.ModelHelper

  alias HTTPoison.Response
  alias Ecto.Changeset

  @url "https://kitsu.io/api/edge/"

	# Image Paths
	@cover_path "/images/cover"
  @poster_path "/images/poster"
  @gallery_path "/images/gallery"

  def populate(changeset = %Changeset{changes: %{kitsu_id: id}}) do
    kitsu_data =
      request("anime", id)
      |> format_to_series
      |> Map.merge(changeset.changes)

    changeset
    |> Changeset.change(kitsu_data)
    |> get_images(:cover_image,  @cover_path)
    |> get_images(:poster_image, @poster_path)
  end
  def populate(changeset), do: changeset

  defp request(type, id) do
    url = @url <> type <> "/" <> id
    headers = ["Accept": "application/vnd.api+json"]
    options = [follow_redirect: true]

    {:ok, %Response{body: body}} = HTTPoison.get(url, headers, options)
    body = Poison.decode!(body)
    Map.put(body["data"]["attributes"], "id", id)
  end

  defp format_to_series(kitsu_series) do
    %{canon_title: kitsu_series["canonicalTitle"],
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

      started_airing_date: get_date(kitsu_series["startDate"]),
      finished_airing_date: get_date(kitsu_series["endDate"]),
    }
  end

  defp get_date(date) do
    case date do
      nil -> nil
      _ -> Date.from_iso8601!(date)
    end
  end

  def get_images(changeset, key, image_path) do
    cond do
      Map.has_key?(changeset.changes, :directory) ->
        series_path = changeset.changes.directory
        get_images(changeset, key, image_path, series_path)
      !is_nil(changeset.data.directory) ->
        series_path = changeset.data.directory
        get_images(changeset, key, image_path, series_path)
      true ->
        changeset
    end
  end

  def get_images(changeset, key, image_path, series_path) do
    case changeset.changes do
      %{^key => nil} ->
        changeset
      %{^key => map} ->
        map =
          Map.new(map, fn {k, v} ->
            filename =  "/" <> k <> ".jpg"
            path = series_path <> image_path
		 	      v = image_path <> get_image(v, path, filename)
		 	      {k, v}
          end)
        Changeset.put_change(changeset, key, map)
    end
  end

  defp get_image(nil, _, _), do: nil
	defp get_image(url, path, filename) do
   	{:ok, %Response{body: body}} = HTTPoison.get(url)
  	full_path = Application.get_env(:animu, :file_root) <> path
    unless File.dir?(path), do: File.mkdir_p!(full_path)
   	File.write!(full_path <> filename, body)
		filename
	end

end

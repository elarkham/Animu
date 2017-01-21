defmodule Animu.SeriesControllerTest do
  use Animu.ConnCase

  alias Animu.Series

  @valid_attrs %{
      canon_title: "some title",
      titles: %{},
      synopsis: "some content",
      slug: "some-slug",

      cover_image: %{},
      poster_image: %{},
      gallery: %{},

      trailers: [],
      tags: [],
      genres: [],

      age_rating: "PG",
      nsfw: false,

      season_number: 1,
      episode_count: 12,
      episode_length: 23,

      kitsu_rating: 3.231,
      kitsu_id: "id",

      directory: "/videos/series",
    }

  # Slug is blank
  @invalid_attrs %{slug: "", canon_title: "some title", directory: "/vidoes/series"}

  setup %{conn: conn} do
    user = %Animu.User{ id: "111", username: "tester" }
    {:ok, jwt, full_claims} = Guardian.encode_and_sign(user)
    {:ok, %{user: user, jwt: jwt, claims: full_claims}}
    conn = conn
      |> put_req_header("authorization", jwt)
      |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, series_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    struct =  %{canon_title: "some title", slug: "old-slug", directory: "/videos/series"}
    changeset = Series.changeset(%Series{}, struct)
    series = Repo.insert! changeset

    conn = get conn, series_path(conn, :show, series)
    assert json_response(conn, 200)["data"] ==
      %{"id" => series.id,
        "canon_title" => series.canon_title,
        "titles" => series.titles,
        "synopsis" => series.synopsis,
        "slug" => series.slug,

        "cover_image" => series.cover_image,
        "poster_image" => series.poster_image,
        "gallery" => series.gallery,

        "trailers" => series.trailers,
        "tags" => series.tags,
        "genres" => series.genres,

        "age_rating" => series.age_rating,
        "nsfw" => series.nsfw,

        "season_number" => series.season_number,
        "episode_count" => series.episode_count,
        "episode_length" => series.episode_length,

        "episodes" => series.episodes,

        "kitsu_rating" => series.kitsu_rating,
        "kitsu_id" => series.kitsu_id,

        "directory" => series.directory,

        "started_airing_date" => series.started_airing_date,
        "finished_airing_date" => series.finished_airing_date,
      }
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, series_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, series_path(conn, :create), series: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Series, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, series_path(conn, :create), series: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    changeset = Series.changeset(%Series{}, %{canon_title: "some_title",
                                              slug: "old-slug",
                                              directory: "/videos/series"})
    series = Repo.insert! changeset
    conn = put conn, series_path(conn, :update, series), series: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Series, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    changeset = Series.changeset(%Series{}, @valid_attrs)
    series = Repo.insert! changeset
    conn = put conn, series_path(conn, :update, series), series: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    changeset = Series.changeset(%Series{}, @valid_attrs)
    series = Repo.insert! changeset
    conn = delete conn, series_path(conn, :delete, series)
    assert response(conn, 204)
    refute Repo.get(Series, series.id)
  end
end

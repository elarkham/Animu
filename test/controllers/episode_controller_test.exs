defmodule Animu.EpisodeControllerTest do
  use Animu.ConnCase

  alias Animu.{Episode, Series}

  @valid_attrs %{
    title: "some title",
    synopsis: "some content",
    thumbnail: %{},
    kitsu_id: "id",

    number: 5.5,
    season_number: 1,

    video: "/videos/video.mp4",
    subtitles: "/videos/video.ssa",
  }

  # Number is string, video is empty
  @invalid_attrs %{title: "some title", number: "5.5", video: ""}

  setup %{conn: conn} do
    # Create Series and insert
    series = %{id: 1, canon_title: "some title", slug: "old-slug", directory: "/videos/series"}
    series = Series.changeset(%Series{}, series) |> Repo.insert!

    # Setup Authorization
    user = %Animu.User{ id: "111", username: "tester" }
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = conn
      |> put_req_header("authorization", jwt)
      |> put_req_header("accept", "application/json")
    {:ok, %{conn: conn, series: series}}
  end

  test "lists all entries on index", %{conn: conn, series: _series} do
    conn = get conn, episode_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn, series: series} do
    struct = %{title: "some title", number: 5.5, video: "/video.mp4"}
    changeset = Episode.changeset_series(%Episode{}, series, struct)
    episode = Repo.insert! changeset

    conn = get conn, episode_path(conn, :show, episode)
    assert json_response(conn, 200)["data"] ==
      %{"id" => episode.id,
        "title" => episode.title,
        "synopsis" => episode.synopsis,
        "thumbnail" => episode.thumbnail,
        "kitsu_id" => episode.kitsu_id,

        "number" => episode.number,
        "season_number" => episode.season_number,
        "airdate" => episode.airdate,

        "video" => episode.video,
        "subtitles" => episode.subtitles,
      }
  end

  test "renders page not found when id is nonexistent", %{conn: conn, series: _series} do
    assert_error_sent 404, fn ->
      get conn, episode_path(conn, :show, -1)
    end
  end

  #test "creates and renders resource when data is valid", %{conn: conn, series: series} do
  #  conn = post conn, episode_path(conn, :create), episode: @valid_attrs
  #  assert json_response(conn, 201)["data"]["id"]
  #  assert Repo.get_by(Episode, @valid_attrs)
  #end

  #test "does not create resource and renders errors when data is invalid", %{conn: conn, series: series} do
  #  conn = post conn, episode_path(conn, :create), episode: @invalid_attrs
  #  assert json_response(conn, 422)["errors"] != %{}
  #end

  test "updates and renders chosen resource when data is valid", %{conn: conn, series: series} do
    struct = %{title: "some title", number: 5.5, video: "/video.mp4"}
    changeset = Episode.changeset_series(%Episode{}, series, struct)
    episode = Repo.insert! changeset

    conn = put conn, episode_path(conn, :update, episode), episode: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Episode, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, series: series} do
    changeset = Episode.changeset_series(%Episode{}, series, @valid_attrs)
    episode = Repo.insert! changeset

    conn = put conn, episode_path(conn, :update, episode), episode: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn, series: series} do
    changeset = Episode.changeset_series(%Episode{}, series, @valid_attrs)
    episode = Repo.insert! changeset

    conn = delete conn, episode_path(conn, :delete, episode)
    assert response(conn, 204)
    refute Repo.get(Episode, episode.id)
  end
end

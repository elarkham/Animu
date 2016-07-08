defmodule Animu.FranchiseControllerTest do
  use Animu.ConnCase

  alias Animu.Franchise
  @valid_attrs %{cover_image: %{}, creator: "some person", description: "A description of franchise", gallery: %{}, poster_image: %{}, slug: "some-slug", tags: [], titles: %{"english" => "some_title"}, trailers: []}
  @invalid_attrs %{slug: "", titles: %{}}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, franchise_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    changeset = Franchise.changeset(%Franchise{}, %{titles: %{"english"=>"old_title"}, slug: "old-slug"})
    franchise = Repo.insert! changeset
    conn = get conn, franchise_path(conn, :show, franchise)
    assert json_response(conn, 200)["data"] == %{"id" => franchise.id,
      "titles" => franchise.titles,
      "creator" => franchise.creator,
      "description" => franchise.description,
      "slug" => franchise.slug,
      "cover_image" => franchise.cover_image,
      "poster_image" => franchise.poster_image,
      "gallery" => franchise.gallery,
      "trailers" => franchise.trailers,
      "tags" => franchise.tags}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, franchise_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, franchise_path(conn, :create), franchise: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Franchise, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, franchise_path(conn, :create), franchise: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    changeset = Franchise.changeset(%Franchise{}, %{titles: %{"english"=>"old_title"}, slug: "old-slug"})
    franchise = Repo.insert! changeset
    conn = put conn, franchise_path(conn, :update, franchise), franchise: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Franchise, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    changeset = Franchise.changeset(%Franchise{}, @valid_attrs)
    franchise = Repo.insert! changeset
    conn = put conn, franchise_path(conn, :update, franchise), franchise: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    changeset = Franchise.changeset(%Franchise{}, @valid_attrs)
    franchise = Repo.insert! changeset
    conn = delete conn, franchise_path(conn, :delete, franchise)
    assert response(conn, 204)
    refute Repo.get(Franchise, franchise.id)
  end
end

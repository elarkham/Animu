defmodule Animu.FranchiseControllerTest do
  use Animu.ConnCase

  alias Animu.Franchise

  @valid_attrs %{cover_image: %{}, creator: "some content", synopsis: "some content",
                 gallery: %{}, poster_image: %{}, slug: "some-content", tags: [],
                 titles: %{"english": "some title"}, trailers: [],
                 canon_title: "some title"}

  @invalid_attrs %{slug: "", canon_title: "some title"}

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
    conn = get conn, franchise_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    changeset = Franchise.changeset(%Franchise{}, %{canon_title: "some title", slug: "old-slug"})
    franchise = Repo.insert! changeset
    conn = get conn, franchise_path(conn, :show, franchise)
    assert json_response(conn, 200)["data"] ==
      %{"id" => franchise.id,
        "canon_title" => franchise.canon_title,
        "titles" => franchise.titles,
        "creator" => franchise.creator,
        "synopsis" => franchise.synopsis,
        "slug" => franchise.slug,
        "cover_image" => franchise.cover_image,
        "poster_image" => franchise.poster_image,
        "gallery" => franchise.gallery,
        "trailers" => franchise.trailers,
        "tags" => franchise.tags,
      }
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
    changeset = Franchise.changeset(%Franchise{}, %{canon_title: "some_title", slug: "old-slug"})
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

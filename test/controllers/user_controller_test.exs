defmodule Animu.UserControllerTest do
  use Animu.ConnCase

  alias Animu.User
  @valid_output_attrs %{ email: "some@email.com",
                         first_name: "John", last_name: "Smith",
                         username: "jsmith"}

  @valid_input_attrs  %{ email: "some@email.com",
                         first_name: "John", last_name: "Smith",
                         username: "jsmith",
                         password: "password", password_confirmation: "password" }

  @invalid_input_attrs %{ first_name: "Smith", last_name: "John",
                          password: "password", password_confirmation: "not_password"}

  setup %{conn: conn} do
    user = %User{ id: "111", username: "tester" }
    {:ok, jwt, full_claims} = Guardian.encode_and_sign(user)
    {:ok, %{user: user, jwt: jwt, claims: full_claims}}
    conn = conn
      |> put_req_header("authorization", jwt)
      |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    changeset = User.changeset(%User{}, @valid_input_attrs)
    user = Repo.insert! changeset
    conn = get conn, user_path(conn, :show, user)
    assert json_response(conn, 200)["data"] ==
      %{"id" => user.id,
        "first_name" => user.first_name,
        "last_name" => user.last_name,
        "email" => user.email,
        "username" => user.username
       }
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_input_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(User, @valid_output_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_input_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    changeset = User.changeset(%User{}, @valid_input_attrs)
    user = Repo.insert! changeset
    conn = put conn, user_path(conn, :update, user), user: @valid_input_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(User, @valid_output_attrs)
  end

  #test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #  user = Repo.insert! %User{}
  #  conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
  #  assert json_response(conn, 422)["errors"] != %{}
  #end

  test "deletes chosen resource", %{conn: conn} do
    changeset = User.changeset(%User{}, @valid_input_attrs)
    user = Repo.insert! changeset
    conn = delete conn, user_path(conn, :delete, user)
    assert response(conn, 204)
    refute Repo.get(User, user.id)
  end
end

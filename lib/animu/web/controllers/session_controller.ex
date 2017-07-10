defmodule Animu.Web.SessionController do
  use Animu.Web, :controller

  plug :scrub_params, "session" when action in [:create]
  action_fallback Animu.Web.FallbackController

  def create(conn, %{"session" => session_params}) do
    case Animu.Session.authenticate(session_params) do
      {:ok, user} ->
        {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user, :token)
        conn
        |> put_status(:created)
        |> render("show.json", jwt: jwt, user: user)

      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json")
    end
  end

  def create(conn, %{"username" => username, "password" => password}) do
    create(conn, %{"session" => %{"username" => username, "password" => password}})
  end

  def delete(conn, _) do
    {:ok, claims} = Guardian.Plug.claims(conn)
    conn
    |> Guardian.Plug.current_token
    |> Guardian.revoke!(claims)
    |> render("delete.json")
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:forbidden)
    |> render(SessionView, "forbidden.json", error: "Not Authenticated")
  end
end

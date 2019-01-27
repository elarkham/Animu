defmodule Animu.Web.SessionController do
  use Animu.Web, :controller

  alias Animu.Auth

  plug :scrub_params, "session" when action in [:create]
  action_fallback Animu.Web.FallbackController

  def create(conn, %{"session" => session_params}) do
    case Animu.Auth.authenticate(session_params) do
      {:ok, user} ->
        {:ok, jwt} = Auth.encode_and_sign(user)
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
    session = %{
      "session" => %{
        "username" => username,
        "password" => password,
      }
    }
    create(conn, session)
  end

end

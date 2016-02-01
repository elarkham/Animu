defmodule Animu.CurrentUserController do
  use Animu.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Animu.SessionController

  def show(conn, _) do
    case decode_and_verify_token(conn) do
      {:ok, _claims} ->
        user = Gaurdian.Plug.current_resource(conn)

        conn
        |> put_status(:ok)
        |> render("show.json", user: user)

      {:error, _reason} ->
        conn
        |> put_status(:not_found)
        |> render(Animu.SessionView, "error,json", error: "Not Found")
    end
  end

  defp decode_and_verify_token(conn) do
    conn
    |> Gaurdian.Plug.current_token
    |> Gaurdian.decode_and_verify
  end

end

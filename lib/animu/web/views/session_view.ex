defmodule Animu.Web.SessionView do
  use Animu.Web, :view

  def render("show.json", %{jwt: jwt, user: user}) do
    user =
      %{ id: user.id,
         first_name: user.first_name,
         last_name: user.last_name,
         email: user.email,
         username: user.username
       }

    %{jwt: jwt, user: user}
  end

  def render("error.json", _) do
    %{error: "Invalid username or password"}
  end

  def render("delete.json", _) do
    %{ok: true}
  end

  def render("forbidden.json", %{error: error}) do
    %{error: error}
  end

end



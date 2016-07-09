defmodule Animu.SessionView do
  use Animu.Web, :view

  def render( "show.json", %{jwt: jwt, user: user} ) do
    %{ jwt: jwt, data: user }
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



defmodule Animu.SessionView do
  use Animu.Web, :view

  def render( "show.json", %{jwt: jwt, user: user} ) do
    %{
      jwt: jwt,
      user: user
    }
  end

  def render("error.json", _) do
    %{error: "Invalid username or password"}
  end

end



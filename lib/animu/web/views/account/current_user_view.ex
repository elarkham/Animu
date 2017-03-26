defmodule Animu.Web.CurrentUserView do
  use Animu.Web, :view

  def render("show.json", %{user: user}) do
    %{user: user}
  end

  def render("error.json", _) do
  end
end

defmodule Animu.Web.UserView do
  use Animu.Web, :view

  def render("index.json", %{users: users}) do
    %{users: render_many(users, Animu.Web.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{user: render_one(user, Animu.Web.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{ id: user.id,
       first_name: user.first_name,
       last_name: user.last_name,
       email: user.email,
       username: user.username
     }
  end
end

defmodule Animu.UserView do
  use Animu.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, Animu.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, Animu.UserView, "user.json")}
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

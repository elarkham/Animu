# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Animu.Repo.insert!(%Animu.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Animu.Repo
alias Animu.Account.User

[
  %{
    first_name: "Ethan",
    last_name:  "Larkham",
    email:      "ethanlarkham@gmail.com",
    username:   "elarkham",
    password:   "password",
  },
]

|> Enum.map(&User.changeset(%User{}, &1))
|> Enum.each(&Repo.insert!(&1))

defmodule Animu.Account do
  @moduledoc """
  The boundary for the Account system
  """
  import Ecto.{Query, Changeset}, warn: false
  alias Animu.Repo

  alias Animu.Account.User

  ##
  # User Interactions
  ##

  @doc """
  Returns list of Users
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Returns single User using it's id

  Raises `Ecto.NoResultsError` if the User does not exist.
  """
  def get_user!(id) do
    Repo.get!(User, id)
  end

  @doc """
  Creates new User
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a User
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end
end

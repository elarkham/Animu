defmodule Animu.Auth do
  alias Animu.Account.User
  alias Animu.Repo

  alias Comeonin.Bcrypt

  def authenticate(%{"username" => username, "password" => password}) do
    Repo.get_by(User, username: String.downcase(username))
    |> check_password(password)
  end

  defp check_password(nil, _), do: {:error, "Incorrect username or password"}
  defp check_password(user, password) do
    case Bcrypt.checkpw(password, user.encrypted_password) do
      true  -> {:ok, user}
      false -> {:error, "Incorrect username or password"}
    end
  end

  def encode_and_sign(%User{} = user) do
    {:ok, token, _claims} = Animu.Auth.Guardian.encode_and_sign(user)
    {:ok, token}
  end

end

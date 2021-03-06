defmodule Animu.TestGuardianSerializer do
  @behaviour Guardian.Serializer

  alias Animu.Account.User

  def for_token(user = %User{}), do: { :ok, "User:#{user.id}" }
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token(user = %User{}), do: { :ok, user }
  def from_token(_), do: { :error, "Unkown resource type" }

end

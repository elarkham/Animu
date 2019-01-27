defmodule Animu.Auth.Guardian do
  use Guardian, otp_app: :animu

  alias Animu.Repo
  alias Animu.Account.User

  def subject_for_token(user = %User{}, _claims) do
    {:ok, "User:#{user.id}"}
  end
  def subject_for_token(_), do: {:error, "Unknown resource type"}

  def resource_from_claims(%{"sub" => "User:" <> id})  do
    #"User:" <> id = claims["sub"]
    id = to_string(id)
    user = Animu.Account.get_user!(id)
    {:ok, user}
  end
  def resource_from_claims(_), do: {:error, "Unkown resource type"}


end

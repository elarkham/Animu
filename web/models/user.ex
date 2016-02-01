defmodule Animu.User do
  use Animu.Web, :model

  @derive {Poison.Encoder, only: [:id, :first_name, :last_name, :email, :username]}

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string

    field :username, :string
    field :password, :string, virtual: true
    field :encrypted_password, :string

    timestamps
  end

  @required_fields ~w(first_name last_name username password)
  @optional_fields ~w(email encrypted_password)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:password, min: 5)
    |> validate_confirmation(:password, message: "Password does not match")
    |> unique_constraint(:username, message: "Username already taken")
    |> generate_encrypted_password
  end

  defp generate_encrypted_password(current_changeset) do
    case current_changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(current_changeset, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        current_changeset
    end
  end

end

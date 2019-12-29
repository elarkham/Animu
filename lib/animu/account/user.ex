defmodule Animu.Account.User do
  use Animu.Ecto.Schema

  alias __MODULE__

  schema "user" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string

    field :username, :string
    field :password, :string, virtual: true
    field :encrypted_password, :string

    timestamps()
  end

  @required_fields ~w(first_name last_name username password)a
  @optional_fields ~w(email)a

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:password, min: 5)
    |> validate_confirmation(:passowrd, message: "Password does not match")
    |> unique_constraint(:username, message: "Username already taken")
    |> gen_password_hash
  end

	def change(%User{} = user) do
		changeset(user, %{})
	end

  defp gen_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        encrypted_pw = Comeonin.Bcrypt.hashpwsalt(password)
        put_change(changeset, :encrypted_password, encrypted_pw)

      _->
        changeset
    end
  end

end

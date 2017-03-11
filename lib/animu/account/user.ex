defmodule Animu.Account.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__, as: User

  @derive {Poison.Encoder, except: [:__meta__]}
  schema "users" do
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

  @doc """
  Returns `%Ecto.Changeset{}` for tracking Franchise changes
  """
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:password, min: 5)
    |> validate_confirmation(:passowrd, message: "Password does not match")
    |> unique_constraint(:username, message: "Username already taken")
    |> generate_encrypted_password
  end

	def change(%User{} = user) do
		changeset(user, %{})
	end

  defp generate_encrypted_password(current_changeset) do
    case current_changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(current_changeset, :encrypted_password,
                   Comeonin.Bcrypt.hashpwsalt(password))
      _->
        current_changeset
    end
  end

end

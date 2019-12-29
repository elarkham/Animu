defmodule Animu.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :first_name, :string, null: false
      add :last_name,  :string, null: false
      add :email,      :string

      add :username,           :string, null: false
      add :encrypted_password, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user, [:username])
  end
end

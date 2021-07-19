defmodule SAC.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :email, :string, primary_key: true
      add :username, :string, null: false

      timestamps
    end
  end
end

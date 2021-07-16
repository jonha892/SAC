defmodule SAC.Repo.Migrations.CreateSeenMovies do
  use Ecto.Migration

  def change do
    create table(:seen_movies, primary_key: false) do
      add :title, :string, null: false, primary_key: true
      add :first_found, :utc_datetime
      add :first_showing, :utc_datetime
      timestamps
    end
  end
end

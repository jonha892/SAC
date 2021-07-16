defmodule SAC.Repo.Migrations.AddSeenMoviesTable do
  use Ecto.Migration

  def change do
    create table(:seen_movies, primary_key: false) do
      add :title, :string, primary_key: true
      add :playtimes, {:array, :utc_datetime}
      timestamps()
    end
  end
end

# null: false,

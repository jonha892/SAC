defmodule SAC.SeenMovie do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:title, :string, []}
  schema "seen_movies" do
    field :first_found, :utc_datetime
    field :first_showing, :utc_datetime

    timestamps()
  end
  #field :title, :string, primary_key: true

  @doc false
  def changeset(movie, attrs) do
    movie
    |> cast(attrs, [:title, :first_found, :first_showing])
    |> validate_required([:title, :first_found, :first_showing])
    |> unique_constraint(:title)
  end

  #def test_insert() do
  #  {:ok, d1} = DateTime.now("Etc/UTC")
  #  d1 = DateTime.truncate(d1, :second)
  #  attrs = %{title: "test_movies", first_found: d1, first_showing: d1 }
  #
  #  %SAC.SeenMovie{}
  #  |> changeset(attrs)
  #  |> SAC.Repo.insert
  #end
end

# SAC.SeenMovie.test_insert()

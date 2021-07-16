defmodule SAC.SeenMovie do
  use Ecto.Schema

  schema "seen_movies" do
    field :title, :string, null: false, primary_key: true
    field :first_found, :utc_datetime
    field :first_showing, :utc_datetime
  end
end


# SAC.Repo.insert(r)
# r = %SAC.SeenMovie{ title: "a", first_found: d1, first_showing: d1 }
# d1 = DateTime.truncate(d1, :second)
# {:ok, d1} = DateTime.now("Etc/UTC")

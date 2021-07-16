defmodule SAC.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:email, :string, []}
  schema "users" do
    field :username, :string

    timestamps()
  end
  #field :title, :string, primary_key: true

  @doc false
  def changeset(movie, attrs) do
    movie
    |> cast(attrs, [:email, :username])
    |> validate_required([:email, :username])
    |> unique_constraint(:email)
  end
end

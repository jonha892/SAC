defmodule SAC.Persistence do
  import Ecto.Query, only: [from: 2]

  def load_seen_movies do
    seen_movies_filename = Application.fetch_env!(:sac, :seen_movies_filename)
    seen_movies = File.read!(seen_movies_filename) |> String.replace("\r", "") |> String.split("\n", trim: true)
    IO.inspect(seen_movies)
    seen_movies
  end

  def append_seen_movie(movie_path) do
    seen_movies_filename = Application.fetch_env!(:sac, :seen_movies_filename)
    {:ok, file} = File.open(seen_movies_filename, [:append])
    IO.binwrite(file, movie_path<>"\n")
    File.close(file)
  end

  def load_recipients do
    recipients_filename = Application.fetch_env!(:sac, :recipients)
    recipients = File.read!(recipients_filename) |> String.replace("\r", "") |> String.split("\n", trim: true)
    IO.inspect(recipients)
    recipients
  end

  def append_recipients(recipient) do
    recipients_filename = Application.fetch_env!(:sac, :recipients)
    {:ok, file} = File.open(recipients_filename, [:append])
    IO.binwrite(file, recipient<>"\n")
    File.close(file)
  end


  def fetch_seen_movies do
    query = from u in "seen_movies",
              select: u.title
    movies = SAC.Repo.all(query)
    movies
  end

  def add_seen_movies(title, first_found, first_showing) do
    attrs = %{title: title, first_found: first_found, first_showing: first_showing}
    %SAC.SeenMovie{}
    |> SAC.SeenMovie.changeset(attrs)
    |> SAC.Repo.insert
  end

  def add_user(email, username) do
    attrs = %{email: email, username: username}
    %SAC.User{}
    |> SAC.User.changeset(attrs)
    |> SAC.Repo.insert
  end

  def delete_user(email) do
    attrs = %{email: email}
    %SAC.User{}
    |> SAC.User.changeset(attrs)
    |> SAC.Repo.delete
  end

  def fetch_users do
    #query = from u in SAC.User
    movies = SAC.Repo.all(SAC.User)
    movies
  end
end


# SAC.Persistence.add_user("test_email", "test_usernanme")
# SAC.Persistence.delete_usere("test")
# SAC.Persistence.fetch_users()
# https://cheatography.com/virviil/cheat-sheets/ecto/

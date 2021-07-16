defmodule SAC.Persistence do
  require Logger

  import Ecto.Query, only: [from: 2]

  def fetch_seen_movie_titles do
    Logger.debug "fetching all seen movies..."
    query = from u in "seen_movies",
              select: u.title
    movies = SAC.Repo.all(query)
    Logger.debug "fetching movies complete"
    movies
  end

  def remove_all_movies() do
    SAC.Repo.delete_all(SAC.SeenMovie)
  end

  def add_seen_movies(title, playtimes) do
    attrs = %{title: title, playtimes: playtimes}
    Logger.info "adding seen movie with attrs: " <> inspect(attrs)
    %SAC.SeenMovie{}
    |> SAC.SeenMovie.changeset(attrs)
    |> SAC.Repo.insert
  end

  def add_user(email, username) do
    Logger.debug "adding a new user with email: " <> email <> " and username: " <> username <> "..."
    attrs = %{email: email, username: username}
    resp = %SAC.User{}
    |> SAC.User.changeset(attrs)
    |> SAC.Repo.insert
    Logger.debug "adding was successful " <> inspect(resp)
    resp
  end

  def delete_user(email) do
    Logger.debug "deleting the user with email: " <> email <> "..."
    attrs = %{email: email}
    resp = %SAC.User{}
    |> SAC.User.changeset(attrs)
    |> SAC.Repo.delete
    Logger.debug "deleting user was successful" <> inspect(resp)
    resp
  end

  def fetch_users do
    Logger.debug "fetching all users..."
    users = SAC.Repo.all(SAC.User)
    Logger.debug "fetching users complete"
    users
  end

end

# Repo mit elixir
# Repo lockt datei.
# Dadurch ist folgendes nicht möglich:
# - Start der app und gleichzeitiges starten von iex
# - Start von zwei iex instanzen

# SAC.Persistence.add_user("test_email", "test_usernanme")
# SAC.Persistence.delete_usere("test")
# SAC.Persistence.fetch_users()
# https://cheatography.com/virviil/cheat-sheets/ecto/

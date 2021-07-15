defmodule SAC.Persistence do
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
end

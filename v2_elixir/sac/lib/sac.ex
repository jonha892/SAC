defmodule SAC do
  use Application
  use Supervisor

  require Logger
  alias SAC.{Email, DiscordBot, Mailer, Downloader, HTMLParser, Util}



  # together with mod in mix.exs
  def start(_type, _args) do
    IO.puts "starting"
    children = [
      {Finch, name: MyFinch
      }
    ]

    opts = [strategy: :one_for_one, name: Sample.Supervisor]

    Supervisor.start_link(children, opts)

    main(:none)
    {:ok, self()}
  end

  defp load_seen_movies do
    seen_movies_filename = Application.fetch_env!(:sac, :seen_movies_filename)
    seen_movies = File.read!(seen_movies_filename) |> String.replace("\r", "") |> String.split("\n", trim: true)
    IO.inspect(seen_movies)
    seen_movies
  end

  defp append_seen_movie(movie_path) do
    seen_movies_filename = Application.fetch_env!(:sac, :seen_movies_filename)
    {:ok, file} = File.open(seen_movies_filename, [:append])
    IO.binwrite(file, movie_path<>"\n")
    File.close(file)
  end

  defp load_recipients do
    recipients_filename = Application.fetch_env!(:sac, :recipients)
    recipients = File.read!(recipients_filename) |> String.replace("\r", "") |> String.split("\n", trim: true)
    IO.inspect(recipients)
    recipients
  end

  defp append_recipients(recipient) do
    recipients_filename = Application.fetch_env!(:sac, :recipients)
    {:ok, file} = File.open(recipients_filename, [:append])
    IO.binwrite(file, recipient<>"\n")
    File.close(file)
  end

  defp find_movies do
    with  {:ok, response} <- Downloader.download_preview_page,
          {:ok, document} <- HTMLParser.parse_response(response),
          movies <- HTMLParser.movies(document)
    do
      {:ok, movies}
    else
      err -> {:err, err}
    end
  end

  defp handle_movie(movie_path) do
    IO.puts movie_path
    with  {:ok, response} <- Downloader.download_movie_page(movie_path),
          {:ok, document} <- HTMLParser.parse_response(response),
          bookableMap <- HTMLParser.is_movie_bookable?(document)
    do
      if bookableMap[:bookable] do
        IO.inspect(bookableMap)
        report_bookable(movie_path, bookableMap[:title], bookableMap[:first_playtime], bookableMap[:dates])
        append_seen_movie(movie_path)
      end
    else
      err -> err
    end
  end

  defp report_bookable(movie_path, title, first_playtime, dates) do
    email_subject = Util.build_email_subject(title)
    email_body = Util.build_email_notification_body(movie_path, title, first_playtime, dates)
    recipients = load_recipients()

    Email.buildReportMail(recipients, email_subject, email_body)
    |> Mailer.deliver_now

    Util.build_discord_notification_body(movie_path, title, first_playtime, dates)
    |> DiscordBot.publish_notification
  end

  def main(_) do
    Logger.debug("Starting the Savoy Availablity Checker v2.0 :)")

    seen_movies = load_seen_movies()
    with {:ok, movie_paths} <- find_movies()
    do
      movie_paths |> Enum.filter(fn movie -> !Enum.member?(seen_movies, movie) end) |> Enum.each(&handle_movie/1)
    else
      err -> err
    end
  end
end

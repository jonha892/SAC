defmodule SAC.Checking do
  require Logger
  #alias SAC.{ Downloader, HTMLParser, Persistence, Util, DiscordBot, Email }
  alias SAC.{Email, DiscordBot, Mailer, Downloader, HTMLParser, Util, Persistence}


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
        Persistence.append_seen_movie(movie_path)
      end
    else
      err -> err
    end
  end

  defp report_bookable(movie_path, title, first_playtime, dates) do
    email_subject = Util.build_email_subject(title)
    email_body = Util.build_email_notification_body(movie_path, title, first_playtime, dates)
    recipients = Persistence.load_recipients()

    Email.buildReportMail(recipients, email_subject, email_body)
    |> Mailer.deliver_now

    Util.build_discord_notification_body(movie_path, title, first_playtime, dates)
    |> DiscordBot.publish_notification
  end

  def main() do
    Logger.debug("Starting the Savoy Availablity Checker v2.0 :)")

    seen_movies = Persistence.load_seen_movies()
    with {:ok, movie_paths} <- find_movies()
    do
      movie_paths |> Enum.filter(fn movie -> !Enum.member?(seen_movies, movie) end) |> Enum.each(&handle_movie/1)
    else
      err -> err
    end
  end
end

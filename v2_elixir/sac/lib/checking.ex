defmodule SAC.Checking do
  require Logger
  alias SAC.{Email, DiscordBot, Mailer, Downloader, HTMLParser, Util, Persistence}


  defp find_movies do
    Logger.info "Scanning for movies..."
    with  {:ok, response} <- Downloader.download_preview_page,
          {:ok, document} <- HTMLParser.parse_response(response),
          movies <- HTMLParser.movies(document)
    do
      Logger.info "...Found movies: " <> inspect movies
      case length movies do
        0 -> {:error, "No movies found! Maybe the Savoy page changed?!?"}
        _ -> {:ok, movies}
      end
    else
      err -> {:err, err}
    end
  end

  defp handle_movie(movie_path) do
    Logger.info "Scanning movie with path: " <> movie_path <> " for playtimes..."
    with  {:ok, response} <- Downloader.download_movie_page(movie_path),
          {:ok, document} <- HTMLParser.parse_response(response),
          bookableMap <- HTMLParser.is_movie_bookable?(document)
    do
      Logger.info "...found: " <> inspect bookableMap
      if bookableMap[:bookable] do
        report_bookable(movie_path, bookableMap[:title], bookableMap[:first_playtime], bookableMap[:dates])
        Persistence.add_seen_movies(bookableMap[:title], bookableMap[:first_playtime], bookableMap[:dates])
      end
    else
      err -> err
    end
  end

  defp report_bookable(movie_path, title, first_playtime, dates) do
    Util.build_discord_notification_body(movie_path, title, first_playtime, dates)
    |> DiscordBot.publish_notification

    email_subject = Util.build_email_subject(title)
    email_body = Util.build_email_notification_body(movie_path, title, first_playtime, dates)
    recipients = Persistence.load_recipients()

    Email.buildReportMail(recipients, email_subject, email_body)
    |> Mailer.deliver_now

  end

  def main() do
    Logger.debug("Starting the Savoy Availablity Checker v2.1 :)")

    with  seen_movies = Persistence.fetch_seen_movies(),
          {:ok, movie_paths} <- find_movies()
    do
      movie_paths |> Enum.filter(fn movie -> !Enum.member?(seen_movies, movie) end) |> Enum.at(0) |> handle_movie #Enum.each(&handle_movie/1)
    else
      err -> err
    end
  end
end

defmodule SAC.Checking do
  require Logger
  alias SAC.{Email, DiscordBot, Mailer, Downloader, HTMLParser, Util, Persistence}


  def find_movies do
    Logger.info "Scanning for movies..."
    with  {:ok, response} <- Downloader.download_preview_page,
          {:ok, document} <- HTMLParser.parse_response(response),
          movies <- HTMLParser.find_movies(:program, document)
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

  # SAC.Checking.handle_movie("/movie/free-guy")
  def handle_movie(movie_title) do
    Logger.info "Scanning movie with path: " <> movie_title <> " for playtimes..."
    with  {:ok, response} <- Downloader.download_movie_page(movie_title),
          {:ok, document} <- HTMLParser.parse_response(response),
          {:ok, movie} <- HTMLParser.parse_movie(document, movie_title)
    do
      Logger.info "...found: " <> inspect movie
      if movie[:bookable] do
        # TODO error handling
        Logger.info "add seen movies: " <> inspect(movie)
        r = Persistence.add_seen_movies(movie[:title], movie[:playtimes])
        Logger.info "add response" <> inspect(r)
        report_bookable(movie_title, movie[:title_pretty], movie[:playtimes])
        #Logger.info "Seen movies after insert: " <> inspect(Persistence.fetch_seen_movies())
      end
    else
      err -> err
    end
  end

  defp report_bookable(movie_title, title, playtimes) do
    Util.build_discord_notification_body(movie_title, title, playtimes)
    |> DiscordBot.Util.publish_seen_movie

    email_subject = Util.build_email_subject(title)
    email_body = Util.build_email_notification_body(movie_title, title, playtimes)
    recipients = Persistence.fetch_users() |> Enum.map(fn user -> user.email end)

    Email.buildReportMail(recipients, email_subject, email_body)
    |> Mailer.deliver_now

  end

  def main() do
    Logger.debug("Starting the Savoy Availablity Checker v2.1 :)")

    with  seen_movies = Persistence.fetch_seen_movie_titles(),
          {:ok, movies} <- find_movies()
    do
      Logger.info "Seen Movies found in Database: " <> inspect(seen_movies)
      movies |> Enum.filter(fn movie -> !Enum.member?(seen_movies, movie) end) |> Enum.each(&handle_movie/1)
    else
      err -> err
    end
  end
end

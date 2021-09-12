defmodule SAC do
  use Application
  use Supervisor
  use Timex

  require Logger
  #alias SAC.{Email, DiscordBot, Mailer, Downloader, HTMLParser, Util}



  # together with mod in mix.exs
  def start(_type, _args) do
    IO.puts "starting"
    children = [
      { Finch, name: MyFinch },
      SAC.Scheduler,
      SAC.DiscordBot,
      SAC.Repo
    ]

    opts = [strategy: :one_for_one, name: SAC.Supervisor]

    Supervisor.start_link(children, opts)
    :logger.add_handlers(:sac)

    #SAC.Persistence.add_user("test_email2", "test_usernanme")
    #SAC.Checking.find_movies() |> inspect |> Logger.info
    #SAC.Checking.main()
    #SAC.Persistence.remove_all_movies()
    #SAC.Checking.handle_movie("free-guy")
    #title = "test"
    #SAC.Persistence.add_seen_movies(title, playtimes)
    #SAC.Persistence.fetch_seen_movies() |> inspect |> Logger.info

    {:ok, self()}
  end
end

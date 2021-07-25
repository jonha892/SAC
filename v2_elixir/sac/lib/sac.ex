defmodule SAC do
  use Application
  use Supervisor

  #require Logger
  #alias SAC.{Email, DiscordBot, Mailer, Downloader, HTMLParser, Util}



  # together with mod in mix.exs
  def start(_type, _args) do
    IO.puts "starting"
    children = [
      { Finch, name: MyFinch },
      SAC.Scheduler,
      SAC.Repo
    ]

    opts = [strategy: :one_for_one, name: SAC.Supervisor]

    Supervisor.start_link(children, opts)

    #SAC.Checking.main()
    SAC.Persistence.add_user("test_email2", "test_usernanme")
    {:ok, self()}
  end
end

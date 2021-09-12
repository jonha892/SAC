defmodule SAC.ErrorHandling do
  require Logger

  def title_error(titles) do
    msg = "Found some weird titles: " <> inspect(titles)
    Logger.error msg
    SAC.DiscordBot.Util.publish_error(msg)
  end
end

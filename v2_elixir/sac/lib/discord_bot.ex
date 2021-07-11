defmodule SAC.DiscordBot do
  require Logger
  alias Nostrum.Api

  @channel String.to_integer(Application.fetch_env!(:sac, :discord_channel))

  def publish_notification(txt) do
    Logger.debug "Publishing the message: " <> txt <> " to the channel " <> Integer.to_string(@channel)
    r = Api.create_message(@channel, txt)
    Logger.debug "Publishing response: " <> inspect r
  end
end

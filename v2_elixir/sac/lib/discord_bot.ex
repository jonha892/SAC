defmodule SAC.DiscordBot do
  use Nostrum.Consumer

  require Logger
  alias Nostrum.Api

  @channel String.to_integer(Application.fetch_env!(:sac, :discord_channel))
  @debug_channel String.to_integer(Application.fetch_env!(:sac, :discord_debug_channel))
  @welcome_channel String.to_integer(Application.fetch_env!(:sac, :discord_welcome_channel))

  @guild_id String.to_integer(Application.fetch_env!(:sac, :discord_guild_id))
  @role_id String.to_integer(Application.fetch_env!(:sac, :discord_role_id))

  @channel_role_name Application.fetch_env!(:sac, :discord_channel_role_name)

  def publish_notification(txt) do
    Logger.debug "Publishing the message: " <> txt <> " to the channel " <> Integer.to_string(@channel)
    r = Api.create_message(@channel, @channel_role_name <> " " <> txt)
    Logger.debug "Publishing response: " <> inspect r
  end

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_REACTION_ADD, msg, _ws_state}) do
    IO.puts("Reaction add channel-emoji #{msg.channel_id} #{inspect(msg.emoji)}")
    IO.puts("Reaction add channel-emoji #{inspect(msg)}")
    case {msg.channel_id, msg.emoji.name} do
      {@welcome_channel, "🎦"} ->
        Logger.debug("Register discord")
        r = Api.add_guild_member_role(@guild_id, msg.user_id, @role_id)
        Logger.debug("Add role-response" <> inspect(r))
      {@welcome_channel, "📧"} ->
        Logger.debug("Register email")
          #Api.create_message(debug_channel, "Discord signup")
      _ -> :ignore
    end
  end

  def handle_event({:MESSAGE_REACTION_REMOVE, msg, _ws_state}) do
    case {msg.channel_id, msg.emoji.name} do
      {@welcome_channel, "🎦"} ->
        Logger.debug("Unregister discord")
        r = Api.remove_guild_member_role(@guild_id, msg.user_id, @role_id)
        Logger.debug("Remove role-response" <> inspect(r))
      {@welcome_channel, "📧"} ->
        Logger.debug("Unregister email")
          #Api.create_message(debug_channel, "Discord signup")
      _ -> :ignore
    end
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end

#SAC.DiscordBot.start_link

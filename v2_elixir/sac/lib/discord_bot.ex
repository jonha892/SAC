defmodule SAC.DiscordBot do
  use Nostrum.Consumer

  require Logger
  alias SAC.DiscordBot.Util

  @debug_channel String.to_integer(Application.fetch_env!(:sac, :discord_debug_channel))
  @welcome_channel String.to_integer(Application.fetch_env!(:sac, :discord_welcome_channel))

  @guild_id String.to_integer(Application.fetch_env!(:sac, :discord_guild_id))
  @role_id String.to_integer(Application.fetch_env!(:sac, :discord_role_id))


  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_REACTION_ADD, msg, _ws_state}) do
    IO.puts("Reaction add channel-emoji #{msg.channel_id} #{inspect(msg.emoji)}")
    IO.puts("Reaction add channel-emoji #{inspect(msg)}")
    case {msg.channel_id, msg.emoji.name} do
      {@welcome_channel, "🎦"} ->
        Logger.debug("Register discord")
        r = Nostrum.Api.add_guild_member_role(@guild_id, msg.user_id, @role_id)
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
        r = Nostrum.Api.remove_guild_member_role(@guild_id, msg.user_id, @role_id)
        Logger.debug("Remove role-response" <> inspect(r))
      {@welcome_channel, "📧"} ->
        Logger.debug("Unregister email")
          #Api.create_message(debug_channel, "Discord signup")
      _ -> :ignore
    end
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    Logger.info "handle event " <> inspect(msg)
    case msg.channel_id do
      @debug_channel -> process_message(msg)
      _ -> :ignore
    end
  end

  def process_message(msg) do
    case String.split(msg.content, " ") do
      ["!list_users"] -> Util.handle_list_users_cmd(msg)
      ["!list_seen_movies"] -> Util.handle_list_movies_cmd(msg)
      ["!add_user", email, username] -> Util.handle_add_user_cmd(msg, email, username)
      ["!remove_user", email] -> Util.handle_remove_user_cmd(msg, email)
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

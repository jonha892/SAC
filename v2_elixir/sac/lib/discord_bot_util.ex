defmodule SAC.DiscordBot.Util do
  require Logger

  require Nostrum.Api
  alias SAC.Persistence

  @debug_channel String.to_integer(Application.fetch_env!(:sac, :discord_debug_channel))
  @notification_channel String.to_integer(Application.fetch_env!(:sac, :discord_channel))
  @channel_role_name Application.fetch_env!(:sac, :discord_channel_role_name)
  @dev_role_name Application.fetch_env!(:sac, :discord_channel_dev_role_name)

  def publish_seen_movie(txt) do
    Logger.debug "Publishing the message: " <> txt <> " to the channel " <> Integer.to_string(@notification_channel)
    r = Nostrum.Api.create_message(@notification_channel, @channel_role_name <> " " <> txt)
    Logger.debug "Publishing response: " <> inspect r
  end

  def handle_list_users_cmd(msg) do
    users = Persistence.fetch_users()
    resp_msg = case length(users) do
      0 -> "List users response: No users known :("
      _ -> "List users response: \n" <> (Enum.map(users, fn user -> "`"<>user.email<>"`" end) |> Enum.join("\n"))
    end

    Nostrum.Api.create_message(msg.channel_id, resp_msg)
  end

  def handle_list_movies_cmd(msg) do
    movies = Persistence.fetch_seen_movie_titles()

    resp_msg = case length(movies) do
      0 -> "List seen_movies response: No movies known :("
      n when n<10 -> "List seen_movies response, found " <> Integer.to_string(n) <> "movies:\n" <> Enum.map(movies, fn movie -> "`"<>movie.title<>"`"  end) |> Enum.join("\n")
      n when n>=10 -> "List seen_movies response, found " <> Integer.to_string(n) <> "movies. Too many to print!"
    end

    Nostrum.Api.create_message(msg.channel_id, resp_msg)
  end

  def handle_add_user_cmd(msg, email, username) do
    {:ok, _} = Persistence.add_user(email, username)

    resp_msg = "Successfully added the new user with email: " <> email <> " and username:" <> username
    Nostrum.Api.create_message(msg.channel_id, resp_msg)
  end

  def handle_remove_user_cmd(msg, email) do
    {:ok, _} = Persistence.remove_user(email)

    resp_msg = "Successfully removed the user with email " <> email <> "."
    Nostrum.Api.create_message(msg.channel_id, resp_msg)
  end

  def publish_error(msg) do
    Nostrum.Api.create_message(@debug_channel, @dev_role_name <> " " <> msg)
  end

end

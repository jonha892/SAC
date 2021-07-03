defmodule SAC.Util do
  require Logger
  def transform_title(title) do
    title |> String.split(" - ") |> Enum.drop(-1) |> Enum.join(" - ") |> String.replace("&amp;", "&")
  end

  def build_email_subject(title) do
    "SAC: Für #{title} können jetzt Karten vorbestellt werden"
  end

  def build_email_notification_body(movie_path, title, first_playtime, dates) do
    movie_url = Application.fetch_env!(:sac, :savoy_base_url) <> movie_path
    Logger.debug("Building the email notification string using movie url: '#{movie_url}' title: '#{title}' first_playtime: '#{first_playtime}' dates : '#{inspect(dates)}'")

    body = """
    Ein neuer Film ist verfügbar: #{title}

    Ab sofort sollte es moeglich sein, auf #{movie_url} Kinokarten fuer '#{title}' vorzubestellen.
    An folgenden Tag(en) wird der Film gezeigt: #{Enum.join(dates, ", ")}
    Am ersten Tag beginnt die Vorstellung um #{first_playtime}.

    Diese E-Mail wird nur einmal versandt.
    """
    body
  end

  def build_discord_notification_body(movie_path, title, first_playtime, dates) do
    movie_url = Application.fetch_env!(:sac, :savoy_base_url) <> movie_path
    Logger.debug("Building the discord notification string using movie url: '#{movie_url}' title: '#{title}' first_playtime: '#{first_playtime}' dates : '#{inspect(dates)}'")

    body = """
    Ein neuer Film ist verfügbar: #{title}

    Ab sofort sollte es moeglich sein, auf #{movie_url} Kinokarten fuer '#{title}' vorzubestellen.
    An folgenden Tag(en) wird der Film gezeigt: #{Enum.join(dates, ", ")}
    Am ersten Tag beginnt die Vorstellung um #{first_playtime}.
    """
    body
  end

  def build_discord_register_text() do
    """
    Notifications:
      1. To subscribe to notifications for a specific product, click the corresponding reaction emoji at the bottom of this message from the list below.
      2. Make sure you have at least "Only @ mentions" turned on within the corresponding channel's notification settings in order to receive notifications.

      :cinema: to get notified via Discord
      :e_mail: to get notified via E-Mail (TODO: implement a way fro the bot to ask the user for their mail and add it to receiver list)
    """
  end
end

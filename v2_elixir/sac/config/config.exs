import Config

config :sac, :savoy_preview_url, "https://savoy.premiumkino.de/veranstaltung/preview"
config :sac, :savoy_programm_url, "https://savoy.premiumkino.de/program"
config :sac, :savoy_base_url, "https://savoy.premiumkino.de"

config :sac, :seen_movies_filename, "./seen_movies.txt"
config :sac, :recipients, "./recipients.txt"

discord_channel = System.get_env("SAC_DISCORD_CHANNEL") || raise "The environment variable 'SAC_DISCORD_CHANNEL' is not set."
config :sac, :discord_channel, discord_channel

bamboo_username = System.get_env("SAC_SENDER_MAIL") || raise "The environment variable 'SAC_SENDER_MAIL' is not set."
bamboo_password = System.get_env("SAC_SENDER_PASSWORD") || raise "The environment variable 'SAC_SENDER_PASSWORD' is not set."

config :sac, :sender, bamboo_username
config :sac, SAC.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.gmail.com",
  hostname: "your.domain",
  port: 587,
  username: bamboo_username,
  password: bamboo_password,
  tls: :if_available, # can be `:always` or `:never`
  allowed_tls_versions: [:"tlsv1", :"tlsv1.1", :"tlsv1.2"], # or {:system, "ALLOWED_TLS_VERSIONS"} w/ comma seprated values (e.g. "tlsv1.1,tlsv1.2")
  tls_log_level: :error,
  ssl: false, # can be `true`
  retries: 1,
  no_mx_lookups: false, # can be `true`
  auth: :if_available # can be `:always`. If your smtp relay requires authentication set it to `:always`.

nostrum_token = System.get_env("NOSTRUM_TOKEN") || raise "The environment variable 'NOSTRUM_TOKEN' is not set."
config :nostrum,
  token: nostrum_token,
  num_shards: 1 # The number of shards you want to run your bot under, or :auto.


#import_config "#{Mix.env()}.exs"
import Config

###
### Scheduling
###
config :sac, SAC.Scheduler,
  jobs: [
    #{"*/15 * * * *",  {SAC.Checking, ":main", []}},
    {"*/30 * * * *",  {SAC.Checking, :main, []}},
  ]

###
### Constants
###
config :sac, :savoy_preview_url, "https://savoy.premiumkino.de/veranstaltung/preview"
config :sac, :savoy_programm_url, "https://savoy.premiumkino.de/program"
config :sac, :savoy_movie_base_url, "https://savoy.premiumkino.de/movie/"

config :sac, :seen_movies_filename, "./seen_movies.txt"
config :sac, :recipients, "./recipients.txt"

###
### Bamboo
###
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



###
### Discord
###
discord_debug_channel = System.get_env("SAC_DISCORD_DEBUG_CHANNEL") || raise "The environment variable 'SAC_DISCORD_DEBUG_CHANNEL' is not set."
config :sac, :discord_debug_channel, discord_debug_channel

discord_welcome_channel = System.get_env("SAC_DISCORD_WELCOME_CHANNEL") || raise "The environment variable 'SAC_DISCORD_WELCOME_CHANNEL' is not set."
config :sac, :discord_welcome_channel, discord_welcome_channel

guild_id = System.get_env("SAC_DISCORD_GUILD_ID") || raise "The environment variable 'SAC_DISCORD_GUILD_ID' is not set."
config :sac, :discord_guild_id, guild_id
role_id = System.get_env("SAC_DISCORD_ROLE_ID") || raise "The environment variable 'SAC_DISCORD_ROLE_ID' is not set."
config :sac, :discord_role_id, role_id
dev_role_id = System.get_env("SAC_DISCORD_DEV_ROLE_ID") || raise "The environment variable 'SAC_DISCORD_DEV_ROLE_ID' is not set."

config :sac, :discord_channel_role_name, "<@&" <> role_id <> ">"
config :sac, :discord_channel_dev_role_name, "<@&" <> dev_role_id <> ">"

nostrum_token = System.get_env("NOSTRUM_TOKEN") || raise "The environment variable 'NOSTRUM_TOKEN' is not set."
config :nostrum,
  token: nostrum_token,
  num_shards: 1 # The number of shards you want to run your bot under, or :auto.

###
### Database
###
config :sac,
  ecto_repos: [SAC.Repo]


import_config "#{Mix.env()}.exs"

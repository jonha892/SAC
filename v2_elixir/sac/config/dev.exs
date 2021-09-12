import Config

###
### Discord
###
### Use debug channel as output channel in dev environment
discord_channel = System.get_env("SAC_DISCORD_DEBUG_CHANNEL") || raise "The environment variable 'SAC_DISCORD_CHANNEL' is not set."
config :sac, :discord_channel, discord_channel

###
### Database
###
db_path = System.get_env("SAC_SQLITE_PATH_DEV") || raise "The environment variable 'SAC_SQLITE_PATH_DEV' is not set."
config :sac, SAC.Repo,
  database: db_path

###
### Logging
###
config :sac, :logger, [
  {:handler, :debug_logger, :logger_disk_log_h,
    %{
      module: :logger_std_h,
      config: %{type: :file, file: 'logs/debug.log', max_no_files: 2, max_no_bytes: 5_242_880}, # 5 MB
      level: :debug,
    }
  },
  {:handler, :error_logger, :logger_disk_log_h,
    %{
      module: :logger_std_h,
      config: %{type: :file, file: 'logs/error.log', max_no_files: 2, max_no_bytes: 5_242_880}, # 5 MB
      level: :error,
    }
  }
]

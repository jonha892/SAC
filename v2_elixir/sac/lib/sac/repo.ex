defmodule SAC.Repo do
  use Ecto.Repo, otp_app: :sac, adapter: Ecto.Adapters.SQLite3
end

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :nadia,
  token: {:system, "TELEGRAM_BOT_TOKEN"}

config :gather_info_telegram_bot,
  telegram_client: Nadia

if Mix.env() == :test, do: import_config("#{Mix.env()}.exs")

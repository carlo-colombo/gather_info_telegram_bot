defmodule GatherInfoTelegramBot.Register do
  use GenServer
  require Logger

  def start_link(_arg) do
    register()
    Task.start_link(__MODULE__, :run, [])
  end

  defp register do
    own = System.get_env("OWN_ADDRESS")
    register = System.get_env("REGISTER_ADDRESS")
    token = System.get_env("TELEGRAM_BOT_TOKEN")
    address = "#{register}/bot#{token}/setwebhook"

    Logger.info("Registering '#{own}' on register '#{address}'")

    case HTTPoison.put(
           address,
           Jason.encode!(%{
             "url" => own
           }),
           [{"Content-Type", "application/json"}]
         ) do
      {:ok, _} -> :ok
      {:error, error} -> Logger.error(inspect(error))
    end
  end

  def run() do
    receive do
    after
      60_000 ->
        register()
        run()
    end
  end
end

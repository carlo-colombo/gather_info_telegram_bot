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

    Logger.info "Registering '#{own}' on register '#{register}'"
    {:ok, _} = HTTPoison.put(register, Jason.encode!(%{
      "url" => own
    }))
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

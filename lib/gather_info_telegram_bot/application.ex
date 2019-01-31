defmodule GatherInfoTelegramBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    :ets.new(:session, [:named_table, :public, read_concurrency: true])
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: GatherInfoTelegramBot.Worker.start_link(arg)
      # {GatherInfoTelegramBot.Worker, arg},
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: GatherInfoTelegramBot.Router,
        options: [port: 9021]
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GatherInfoTelegramBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

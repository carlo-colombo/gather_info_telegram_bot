defmodule GatherInfoTelegramBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :gather_info_telegram_bot,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {GatherInfoTelegramBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.1"},
      {:nadia, "~> 0.4.4"},
      {:exsync, "~> 0.2", only: :dev},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:credo, "~> 1.1.4", only: [:dev, :test], runtime: false},
      {:mox, "~> 0.4.0", only: :test},
      {:distillery, "~> 2.0"}
    ]
  end
end

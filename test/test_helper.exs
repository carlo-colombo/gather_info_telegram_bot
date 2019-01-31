ExUnit.start()

Mox.defmock(NadiaMock, for: Nadia.Behaviour)
Application.put_env(:gather_info_telegram_bot, :telegram_client, NadiaMock)

defmodule TokenValidation do
  use Plug.Builder

  plug(:validate)

  def validate(conn = %{params: params}, _opts) do
    if Map.get(params, "token") != Nadia.Config.token() do
      conn
      |> send_resp(501, "Invalid token")
      |> halt
    else
      conn
    end
  end
end

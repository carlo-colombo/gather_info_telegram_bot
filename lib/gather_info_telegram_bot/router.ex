defmodule GatherInfoTelegramBot.Router do
  use Plug.Router

  plug(Plug.Logger)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:match)
  plug(TokenValidation)
  plug(:as_session_id)
  plug(Plug.Session, store: GatherInfoTelegramBot.ETS, key: "chat_id", table: :session)
  plug(:fetch)
  plug(:dispatch)

  post("/api/:token/hook", to: GatherInfoTelegramBot.Handler)

  match _ do
    send_resp(conn, 404, "oops")
  end

  defp fetch(conn, _opts), do: fetch_session(conn)

  defp as_session_id(conn = %{body_params: %{"message" => %{"chat" => %{"id" => id}}}}, _opts) do
    conn
    |> assign(:chat_id, id)
    |> put_req_header("cookie", "chat_id=#{id}")
  end
end

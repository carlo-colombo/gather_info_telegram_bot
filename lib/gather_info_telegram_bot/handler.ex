defmodule GatherInfoTelegramBot.Handler do
  import Plug.Conn
  use Plug.Builder

  plug(:handle)
  plug(:success)
  plug(:serialise)

  defp success(conn, _) do
    if conn.assigns[:error] == nil, do: assign(conn, :accepted, true), else: conn
  end

  def serialise(conn, _) do
    send_resp(conn, 200, Jason.encode!(conn.assigns, %{pretty: true}))
  end

  defp handle(conn, _opts), do: handle_message(conn, conn.body_params["message"])

  defp handle_message(conn, %{"location" => location}),
    do: conn |> put_session(:location, location) |> assign(:handler, :location)

  defp handle_message(conn, %{"text" => "/help"}) do
    conn =
      case get_client().send_message(conn.assigns[:chat_id], "help message", []) do
        {:ok, _} -> conn
        {:error, error} -> assign(conn, :error, error)
      end

    assign(conn, :handler, :help)
  end

  defp handle_message(conn, %{"text" => "/recap"}) do
    conn =
      case get_session(conn, :location) do
        nil ->
          case get_client().send_message(conn.assigns[:chat_id], "No information gathered", []) do
            {:ok, _} -> conn
            {:error, error} -> assign(conn, :error, error)
          end

        %{"latitude" => lat, "longitude" => long} ->
          case get_client().send_location(conn.assigns[:chat_id], lat, long, []) do
            {:ok, _} -> conn
            {:error, error} -> assign(conn, :error, error)
          end
      end

    assign(conn, :handler, :recap)
  end

  defp handle_message(conn, %{"text" => "/reset"}),
    do: conn |> clear_session |> assign(:handler, :reset)

  defp handle_message(conn, %{"text" => text}),
    do: conn |> put_session(:description, text) |> assign(:handler, :description)

  defp handle_message(conn, _), do: conn |> assign(:handler, :catchall)

  defp get_client, do: Application.get_env(:gather_info_telegram_bot, :telegram_client)
end

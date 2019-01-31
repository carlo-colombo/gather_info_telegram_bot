defmodule GatherInfoTelegramBot.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mox
  setup :verify_on_exit!

  setup_all do
    Application.put_env(:gather_info_telegram_bot, :telegram_client, NadiaMock)
    :ok
  end

  setup do
    on_exit(&clear_ets/0)
  end

  test "chat_id as cookie" do
    conn = conn(:post, "/api/a_valid_token/hook", %{"message" => %{"chat" => %{"id" => 1234}}})

    conn = GatherInfoTelegramBot.Router.call(conn, [])

    assert_ok(conn)
    assert conn.req_cookies == %{"chat_id" => "1234"}
  end

  test "when receive a location store message in session" do
    conn =
      conn(:post, "/api/a_valid_token/hook", %{
        "message" => %{
          "chat" => %{"id" => 1234},
          "location" => %{"latitude" => 42, "longitude" => 9}
        }
      })
      |> GatherInfoTelegramBot.Router.call([])

    assert_ok(conn)
    assert get_session(conn, :location) == %{"latitude" => 42, "longitude" => 9}
  end

  test "when receive a description store message in session" do
    conn =
      conn(:post, "/api/a_valid_token/hook", make_text(1234, "this a description"))
      |> GatherInfoTelegramBot.Router.call([])

    assert_ok(conn)
    assert get_session(conn, :description) == "this a description"
  end

  test "when receive a /reset clear the session" do
    GatherInfoTelegramBot.ETS.put(nil, "1234", %{"location" => :foo}, :session)

    conn =
      conn(:post, "/api/a_valid_token/hook", make_text(1234, "/reset"))
      |> GatherInfoTelegramBot.Router.call([])

    assert_ok(conn)
    assert get_session(conn, :location) == nil
    assert get_session(conn, :description) == nil
  end

  test "when receive a /help message send a help message" do
    NadiaMock
    |> expect(:send_message, fn 1234, "help message", _ -> {:ok, %{}} end)

    conn =
      conn(:post, "/api/a_valid_token/hook", make_text(1234, "/help"))
      |> GatherInfoTelegramBot.Router.call([])

    assert_ok(conn)
  end

  describe "when the session is empty" do
    test "receive a /recap" do
      NadiaMock
      |> expect(:send_message, fn chat_id, text, _ ->
        assert chat_id == 1234
        assert text == "No information gathered"
        {:ok, %{}}
      end)

      conn =
        conn(:post, "/api/a_valid_token/hook", make_text(1234, "/recap"))
        |> GatherInfoTelegramBot.Router.call([])

      assert_ok(conn)
    end
  end

  describe "when session contains location" do
    setup :set_location

    test "receive a /recap", context do
      NadiaMock
      |> expect(:send_message, 0, fn _,_,_-> {:ok, nil} end)
      |> expect(:send_location, fn chat_id, lat, long, _ ->
        assert chat_id == 1234
        assert lat == context["location"]["latitude"]
        assert long == context["location"]["longitude"]

        {:ok, %{}}
      end)

      conn =
        conn(:post, "/api/a_valid_token/hook", make_text(1234, "/recap"))
        |> GatherInfoTelegramBot.Router.call([])

      assert_ok(conn)
    end
  end

  defp set_location(_) do
    location = %{"location" => %{"latitude" => 42, "longitude" => 9}}

    GatherInfoTelegramBot.ETS.put(nil, "1234", location, :session)

    on_exit(&clear_ets/0)

    location
  end

  defp clear_ets, do: GatherInfoTelegramBot.ETS.delete(nil, "1234", :session)

  test "when send_message fails still return 200" do
    NadiaMock
    |> expect(:send_message, fn _, _, _ -> {:error, "error"} end)

    conn =
      conn(:post, "/api/a_valid_token/hook", make_text(1234, "/help"))
      |> GatherInfoTelegramBot.Router.call([])

    assert conn.state == :sent
    assert conn.status == 200
    assert %{"error" => "error"} = Jason.decode!(conn.resp_body)
  end

  defp assert_ok(conn) do
    assert conn.state == :sent
    assert conn.status == 200
    assert %{"accepted" => accepted} = Jason.decode!(conn.resp_body)
  end

  defp make_text(chat_id, text),
    do: %{
      "message" => %{
        "chat" => %{
          "id" => chat_id
        },
        "text" => text
      }
    }
end

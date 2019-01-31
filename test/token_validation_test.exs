defmodule TokenValidationTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "return 501 in token invalid and send the connection" do
    conn = conn(:post, "does not matter", %{"token" => "invalidToken"})

    conn = TokenValidation.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 501
    assert conn.resp_body == "Invalid token"
  end

  test "if token match let the connection trough" do
    conn = conn(:post, "does not matter", %{"token" => "a_valid_token"})

    conn = TokenValidation.call(conn, [])

    assert conn.state == :unset
    assert conn.status == nil
  end
end

 defmodule TwilioAuthTest do
  use ExUnit.Case, async: true
  use Plug.Test

  def build_conn() do
    conn(
      :POST,
      "/some/path?qp1=123&qp2=asdf",
      %{
        rightsideup: "upsidedown",
        foo: "bar"
      }
    ) |> Map.put(:scheme, :https)
  end

  def add_signature(conn, auth_token) do
    sig = "https://www.example.com/some/path?qp1=123&qp2=asdffoobarrightsideupupsidedown"
    |> (fn (val) -> :crypto.hmac(:sha, auth_token, val) end).()
    |> Base.encode64

    Plug.Conn.put_req_header(conn, "x-twilio-signature", sig)
  end

  describe "enabled" do
    defmodule TestPlug do
      use Plug.Builder

      plug Plug.Parsers,
        parsers: [:urlencoded, :multipart, :json],
        pass: ["*/*"],
        json_decoder: Poison
      plug TwilioAuth, auth_token: "I_AM_AN_AUTH_TOKEN"
      plug :success

      def success(conn, _opts) do
        conn |> Plug.Conn.send_resp(200, "Hurray")
      end
    end

    test "passes auth" do
      conn = build_conn()
      |> add_signature("I_AM_AN_AUTH_TOKEN")
      |> TestPlug.call(TestPlug.init([]))

      assert conn.status == 200
      assert conn.resp_body == "Hurray"
    end

    test "fails auth if wrong auth token used" do
      conn = build_conn()
      |> add_signature("BAD_TOKEN")
      |> TestPlug.call(TestPlug.init([]))

      assert conn.status == 401
      assert conn.resp_body == "401 Unauthorized"
    end

    test "fails auth if signature header not provided" do
      conn = build_conn()
      |> TestPlug.call(TestPlug.init([]))

      assert conn.status == 401
    end

    test "fails auth if no https" do
      conn = build_conn()
      |> add_signature("I_AM_AN_AUTH_TOKEN")
      |> Map.put(:scheme, :http)
      |> TestPlug.call(TestPlug.init([]))

      assert conn.status == 401
    end

    test "works in the absence of query params" do
      conn = conn(:POST, "/some/path", %{
        rightsideup: "upsidedown",
        foo: "bar"
      }) |> Map.put(:scheme, "https")

      sig = "https://www.example.com/some/pathfoobarrightsideupupsidedown"
      |> (fn (val) -> :crypto.hmac(:sha, "I_AM_AN_AUTH_TOKEN", val) end).()
      |> Base.encode64()

      result = conn
      |> Plug.Conn.put_req_header("x-twilio-signature", sig)
      |> TestPlug.call(TestPlug.init([]))

      assert result.status == 200
    end
  end


  describe "disabled" do
    defmodule NoAuthPlug do
      use Plug.Builder

      plug Plug.Parsers,
        parsers: [:urlencoded, :multipart, :json],
        pass: ["*/*"],
        json_decoder: Poison
      plug TwilioAuth, auth_token: "I_AM_AN_AUTH_TOKEN", enabled: false
      plug :success

      def success(conn, _opts) do
        conn |> Plug.Conn.send_resp(200, "Hurray")
      end
    end

    test "attempts no auth when disabled" do
      conn = build_conn()
      |> NoAuthPlug.call(NoAuthPlug.init([]))

      assert conn.status == 200
    end
  end
end

defmodule TwilioAuth do
  @behaviour Plug

  @spec init(Plug.opts) :: Plug.opts
  def init(options) do
    [
      {:auth_token, Keyword.get(options, :auth_token, '')},
      {:enabled, Keyword.get(options, :enabled, true)}
    ]
  end

  @spec call(Plug.Conn.t, Plug.opts) :: Plug.Conn.t
  def call(conn, auth_token: auth_token, enabled: enabled) do
    case authenticate!(conn, auth_token, enabled) do
      :authorized ->
        conn
      _ ->
        conn
        |> Plug.Conn.send_resp(401, "401 Unauthorized")
        |> Plug.Conn.halt
    end
  end

  @spec authenticate!(Plug.Conn.t, String.t, boolean()) :: atom()
  defp authenticate!(_, _, false), do: :authorized
  defp authenticate!(conn, auth_token, _enabled) do
    local_value    = build_local(conn, auth_token)
    provided_value = conn
    |> Plug.Conn.get_req_header("x-twilio-signature")
    |> to_string()

    case local_value == provided_value do
      true  -> :authorized
      false -> :unauthorized
    end
  end

  @spec build_local(Plug.Conn.t, String.t) :: String.t
  defp build_local(conn, auth_token) do
    scheme       = conn.scheme
    host         = conn.host
    path         = conn.request_path
    query_string = conn.query_string
    post_content = post_string(conn)

    "#{scheme}://#{host}#{path}?#{query_string}#{post_content}"
    |> hmac_sha256(auth_token)
    |> Base.encode64
  end

  @spec post_string(Plug.Conn.t) :: String.t
  defp post_string(conn) do
    conn
    |> Map.get(:body_params, %{})
    |> remove_query_params(conn)
    |> Map.to_list()
    |> Enum.sort()
    |> Enum.map(fn {key, value} -> key <> value end)
    |> Enum.join()
  end

  @spec remove_query_params(map(), Plug.Conn.t) :: map()
  defp remove_query_params(all_params, conn) do
    all_params
    |> Map.drop(conn.query_params |> Map.keys())
  end

  @spec hmac_sha256(String.t, String.t) :: binary()
  defp hmac_sha256(value, token) do
    :crypto.hmac(:sha256, token, value)
  end
end

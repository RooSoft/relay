defmodule RelayWeb.Plugs.SocketDispatcher do
  @moduledoc false
  #
  # How WebSockets Work In Phoenix
  #
  # WebSocket support in Phoenix is implemented on top of the `WebSockAdapter` library. Upgrade
  # requests from clients originate as regular HTTP requests that get routed to this module via
  # Plug. These requests are then upgraded to WebSocket connections via
  # `WebSockAdapter.upgrade/4`, which takes as an argument the handler for a given socket endpoint
  # as configured in the application's Endpoint. This handler module must implement the
  # transport-agnostic `Phoenix.Socket.Transport` behaviour (this same behaviour is also used for
  # other transports such as long polling). Because this behaviour is a superset of the `WebSock`
  # behaviour, the `WebSock` library is able to use the callbacks in the `WebSock` behaviour to
  # call this handler module directly for the rest of the WebSocket connection's lifetime.
  #
  @behaviour Plug

  import Plug.Conn

  require Logger

  alias Phoenix.Socket.{Transport}
  alias Relay.Nostr.Nip11Document
  alias RelayWeb.Sockets.RequestSocket
  alias RelayWeb.Plugs.SocketDispatcher.{Headers}

  @max_frame_size Application.compile_env(:relay, :max_frame_size, 1024 * 1024 / 2)

  def init(opts), do: opts

  def call(conn, opts) do
    case Headers.request_type(conn) do
      :websocket_upgrade ->
        upgrade_connection(conn, opts)

      :nip11_document ->
        send_nip11_document(conn)

      _ ->
        conn
    end
  end

  def handle_error(conn, _reason) do
    send_resp(conn, 403, "")
  end

  defp upgrade_connection(conn, opts) do
    endpoint = RelayWeb.Endpoint
    handler = RequestSocket

    websocket_options =
      Enum.into(opts, %{})
      |> Map.get(:websocket, [])
      |> Enum.into(%{})

    conn
    |> fetch_query_params()
    |> Transport.code_reload(endpoint, opts)
    |> Transport.transport_log(opts[:transport_log])
    |> Transport.check_subprotocols(opts[:subprotocols])
    |> case do
      %{halted: true} = conn ->
        conn

      %{params: params} = conn ->
        keys = Map.get(websocket_options, :connect_info, [])
        connect_info = Transport.connect_info(conn, endpoint, keys)

        config = %{
          endpoint: endpoint,
          transport: :websocket,
          options: websocket_options,
          params: params,
          connect_info: connect_info
        }

        case handler.connect(config) do
          {:ok, arg} ->
            conn
            |> WebSockAdapter.upgrade(handler, arg,
              compress: websocket_options.compress,
              timeout: websocket_options.connection_timeout,
              max_frame_size: @max_frame_size
            )
            |> halt()

          :error ->
            send_resp(conn, 403, "")

          {:error, reason} ->
            {m, f, args} = opts[:error_handler]
            apply(m, f, [conn, reason | args])
        end
    end
  end

  defp send_nip11_document(conn) do
    Logger.info("nip11 document requested by #{inspect(conn.remote_ip)}")

    json =
      Nip11Document.get()
      |> Jason.encode!()

    conn
    |> resp(200, json)
    |> send_resp
    |> halt
  end
end

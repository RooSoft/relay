defmodule RelayWeb.Plugs.SocketDispatcher.Headers do
  def request_type(%{req_headers: request_headers}) do
    headers =
      request_headers
      |> downcase_keys_and_values
      |> Enum.into(%{})

    case headers do
      %{"accept" => "application/nostr+json"} ->
        :nip11_document

      %{"connection" => "upgrade"} ->
        :websocket_upgrade

      _ ->
        :unknown
    end
  end

  defp downcase_keys_and_values(headers) do
    headers
    |> Enum.map(fn {key, value} ->
      {String.downcase(key), String.downcase(value)}
    end)
  end
end

defmodule Relay.Event.Parser do
  @moduledoc """
  Turns raw events from JSON websocket messages into elixir structs
  """

  alias Relay.Event

  def parse(%{
        "content" => content,
        "created_at" => unix_created_at,
        "id" => hex_id,
        "kind" => kind,
        "pubkey" => hex_pubkey,
        "sig" => hex_sig,
        "tags" => hex_tags
      }) do
    id = Binary.from_hex(hex_id)
    pubkey = Binary.from_hex(hex_pubkey)
    sig = Binary.from_hex(hex_sig)
    tags = parse_tags(hex_tags)
    created_at = parse_created_at(unix_created_at)

    %Event{
      id: id,
      content: content,
      created_at: created_at,
      kind: kind,
      pubkey: pubkey,
      sig: sig,
      tags: tags
    }
  end

  defp parse_created_at(unix_created_at) do
    case DateTime.from_unix(unix_created_at) do
      {:ok, created_at} -> created_at
      {:error, _message} -> nil
    end
  end

  defp parse_content(json_content) do
    case Jason.decode(json_content) do
      {:ok, content} -> content
      {:error, _} -> nil
    end
  end

  def parse_tags(hex_tags) do
    hex_tags
    |> Enum.map(fn [type | [hex_id | rest]] = original_version ->
      case Base.decode16(hex_id, case: :mixed) do
        :error -> original_version
        {:ok, id} -> [type | [id | rest]]
      end
    end)
  end
end

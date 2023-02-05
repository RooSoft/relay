defmodule Relay.Event do
  @moduledoc """
  Represents the basic structure of anything that's being sent to/from relays
  """

  require Logger

  defstruct [:id, :pubkey, :created_at, :kind, :tags, :content, :sig]

  alias Relay.Event
  alias Relay.Event.Parser
  alias Relay.Crypto

  @type t :: %Event{}

  # This thing is needed so that the Jason library knows how to serialize the events
  defimpl Jason.Encoder do
    def encode(
          %Event{
            id: id,
            pubkey: pubkey,
            created_at: created_at,
            kind: kind,
            sig: sig,
            tags: tags,
            content: content
          },
          opts
        ) do
      hex_id = Binary.to_hex(id)
      hex_pubkey = Binary.to_hex(pubkey)
      hex_sig = Binary.to_hex(sig)
      timestamp = DateTime.to_unix(created_at)

      Jason.Encode.map(
        %{
          "id" => hex_id,
          "pubkey" => hex_pubkey,
          "created_at" => timestamp,
          "kind" => kind,
          "tags" => tags,
          "content" => content,
          "sig" => hex_sig
        },
        opts
      )
    end
  end

  @spec parse(map()) :: Event.t()
  def parse(body) do
    Parser.parse(body)
  end

  def add_id(event) do
    id = create_id(event)

    %{event | id: id}
  end

  def create_id(%Event{} = event) do
    event
    |> json_for_id()
    |> Crypto.sha256()
    |> Binary.to_hex()
  end

  def json_for_id(%Event{
        pubkey: pubkey,
        created_at: created_at,
        kind: kind,
        tags: tags,
        content: content
      }) do
    hex_pubkey = Binary.to_hex(pubkey)
    timestamp = DateTime.to_unix(created_at)

    [
      0,
      hex_pubkey,
      timestamp,
      kind,
      tags,
      content
    ]
    |> Jason.encode!()
  end
end

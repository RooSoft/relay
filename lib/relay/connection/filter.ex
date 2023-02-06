defmodule Relay.Connection.Filter do
  defstruct [
    :subscription_id,
    :since,
    :until,
    :limit,
    ids: [],
    authors: [],
    kinds: [],
    e: [],
    p: []
  ]

  @metadata_kind 0
  @note_kind 1
  @contacts_kind 3

  alias Relay.Connection.{Filter, FilterRegistry}
  alias Relay.Connection.Filter.Parser

  def from_query(query, subscription_id) do
    Parser.from_req(query, subscription_id)
  end

  def handle(%Filter{subscription_id: subscription_id, kinds: [@metadata_kind]} = filter) do
    IO.inspect(filter, label: "#{subscription_id} METADATA REQ")

    FilterRegistry.subscribe(filter)

    ["EOSE", subscription_id]
  end

  def handle(%Filter{subscription_id: subscription_id, kinds: [@contacts_kind]} = filter) do
    IO.inspect(filter, label: "#{subscription_id} CONTACTS REQ")

    FilterRegistry.subscribe(filter)

    result = ["EOSE", subscription_id]

    IO.inspect(result, label: "#{subscription_id} RETURNING")
  end

  def handle(%Filter{subscription_id: subscription_id, kinds: [@note_kind]} = filter) do
    IO.inspect(filter, label: "#{subscription_id} NOTE REQ")

    FilterRegistry.subscribe(filter)

    result = ["EOSE", subscription_id]

    IO.inspect(result, label: "#{subscription_id} RETURNING")
  end

  def handle(%Filter{subscription_id: subscription_id} = filter) do
    IO.inspect(filter, label: "UNKNOWN REQ")

    FilterRegistry.subscribe(filter)

    ["EOSE", subscription_id]
  end
end

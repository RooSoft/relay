defmodule Relay.Connection.Filter do
  defstruct [:id, :since, :until, :limit, ids: [], authors: [], kinds: [], e: [], p: []]

  @metadata_kind 0
  @note_kind 1
  @contacts_kind 3

  alias Relay.Connection.{Filter, FilterRegistry}
  alias Relay.Connection.Filter.Parser

  def from_query(query, filter_id) do
    Parser.from_req(query, filter_id)
  end

  def handle(%Filter{id: id, kinds: [@metadata_kind]} = filter) do
    IO.inspect(filter, label: "#{id} METADATA REQ")

    FilterRegistry.subscribe(filter)

    ["EOSE", id]
  end

  def handle(%Filter{id: id, kinds: [@contacts_kind]} = filter) do
    IO.inspect(filter, label: "#{id} CONTACTS REQ")

    FilterRegistry.subscribe(filter)

    result = ["EOSE", id]

    IO.inspect(result, label: "#{id} RETURNING")
  end

  def handle(%Filter{id: id, kinds: [@note_kind]} = filter) do
    IO.inspect(filter, label: "#{id} NOTE REQ")

    FilterRegistry.subscribe(filter)

    result = ["EOSE", id]

    IO.inspect(result, label: "#{id} RETURNING")
  end

  def handle(%Filter{id: id} = filter) do
    IO.inspect(filter, label: "UNKNOWN REQ")

    FilterRegistry.subscribe(filter)

    ["EOSE", id]
  end
end

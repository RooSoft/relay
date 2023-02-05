defmodule Relay.Connection.Subscription do
  defstruct [:id, :since, :until, :limit, ids: [], authors: [], kinds: [], e: [], p: []]

  @metadata_kind 0
  @note_kind 1
  @contacts_kind 3

  alias Relay.Connection.{Subscription, SubscriptionRegistry}
  alias Relay.Connection.Subscription.Parser

  def from_query(query, subscription_id) do
    Parser.from_req(query, subscription_id)
  end

  def handle(%Subscription{id: id, kinds: [@metadata_kind]} = subscription) do
    IO.inspect(subscription, label: "#{id} METADATA REQ")

    SubscriptionRegistry.subscribe(subscription)

    ["EOSE", id]
  end

  def handle(%Subscription{id: id, kinds: [@contacts_kind]} = subscription) do
    IO.inspect(subscription, label: "#{id} CONTACTS REQ")

    SubscriptionRegistry.subscribe(subscription)

    result = ["EOSE", id]

    IO.inspect(result, label: "#{id} RETURNING")
  end

  def handle(%Subscription{id: id, kinds: [@note_kind]} = subscription) do
    IO.inspect(subscription, label: "#{id} NOTE REQ")

    SubscriptionRegistry.subscribe(subscription)

    result = ["EOSE", id]

    IO.inspect(result, label: "#{id} RETURNING")
  end

  def handle(%Subscription{id: id} = subscription) do
    IO.inspect(subscription, label: "UNKNOWN REQ")

    SubscriptionRegistry.subscribe(subscription)

    ["EOSE", id]
  end
end

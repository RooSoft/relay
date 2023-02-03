defmodule Relay.Connection.Subscription do
  defstruct [:id, :since, :until, :limit, ids: [], authors: [], kinds: [], e: [], p: []]

  @metadata_kind 0
  @contacts_kind 3

  alias Relay.Connection.{Subscription, SubscriptionRegistry}

  def from_query(query, subscription_id) do
    %Subscription{
      id: subscription_id,
      since: Map.get(query, "since"),
      until: Map.get(query, "until"),
      limit: Map.get(query, "limit"),
      ids: Map.get(query, "ids"),
      authors: Map.get(query, "authors"),
      kinds: Map.get(query, "kinds"),
      e: Map.get(query, "e"),
      p: Map.get(query, "p")
    }
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

  def handle(%Subscription{id: id} = subscription) do
    IO.inspect(subscription, label: "UNKNOWN REQ")

    SubscriptionRegistry.subscribe(subscription)

    ["EOSE", id]
  end
end

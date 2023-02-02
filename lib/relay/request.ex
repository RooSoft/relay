defmodule Relay.Request do
  alias Relay.Request.{Subscription, SubscriptionRegistry}

  def handle(["EVENT", event]) do
    IO.inspect(event, label: "NEW EVENT")

    IO.inspect(SubscriptionRegistry.lookup())
  end

  def handle(["REQ", subscription_id, %{"kinds" => [0]} = query] = req, _peer) do
    IO.inspect(query, label: "#{subscription_id} METADATA EVENT")

    subscribe(req)

    ["EOSE", subscription_id]
  end

  def handle(["REQ", subscription_id, %{"kinds" => [3]} = query] = req, _peer) do
    IO.inspect(query, label: "#{subscription_id} CONTACTS EVENT")

    subscribe(req)

    result = ["EOSE", subscription_id]

    IO.inspect(result, label: "#{subscription_id} RETURNING")
  end

  def handle(["REQ", subscription_id, query] = req, _peer) do
    IO.inspect(query, label: "#{subscription_id} UNKNOWN EVENT")

    subscribe(req)

    ["EOSE", subscription_id]
  end

  def handle(["CLOSE", subscription_id], _peer) do
    IO.inspect(subscription_id, label: "CLOSE COMMAND")

    []
  end

  def handle(unknown, _peer) do
    IO.inspect(unknown, label: "UNKNOWN COMMAND")

    []
  end

  def terminate(peer) do
    IO.inspect(peer, label: "TERMINATE in Relay.Request")
  end

  defp subscribe(req) do
    req
    |> Subscription.from_req()
    |> SubscriptionRegistry.subscribe()
    |> IO.inspect()
  end
end

defmodule Relay.Request do
  def handle(["REQ", subscription_id, %{"kinds" => [0]} = query], _peer) do
    IO.inspect(query, label: "#{subscription_id} METADATA EVENT")

    ["EOSE", subscription_id]
  end

  def handle(["REQ", subscription_id, %{"kinds" => [3]} = query], peer) do
    IO.inspect(query, label: "#{subscription_id} CONTACTS EVENT")

    result = ["EOSE", subscription_id]

    IO.inspect(result, label: "#{subscription_id} RETURNING")
  end

  def handle(["REQ", subscription_id, query], _peer) do
    IO.inspect(query, label: "#{subscription_id} UNKNOWN EVENT")

    ["EOSE", subscription_id]
  end

  def handle(unknown, _peer) do
    IO.inspect(unknown, label: "UNKNOWN COMMAND")

    []
  end
end

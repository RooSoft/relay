defmodule Relay.Request do
  def handle(["REQ", subscription_id, %{"kinds" => [0]} = query]) do
    IO.inspect(query, label: "#{subscription_id} METADATA EVENT")

    ["EOSE", subscription_id]
  end

  def handle(["REQ", subscription_id, %{"kinds" => [3]} = query]) do
    IO.inspect(query, label: "#{subscription_id} CONTACTS EVENT")

    ["EOSE", subscription_id]
  end

  def handle(["REQ", subscription_id, query]) do
    IO.inspect(query, label: "#{subscription_id} UNKNOWN EVENT")

    ["EOSE", subscription_id]
  end

  def handle(unknown) do
    IO.inspect(unknown, label: "UNKNOWN COMMAND")

    []
  end
end

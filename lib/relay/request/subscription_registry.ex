defmodule Relay.Request.SubscriptionRegistry do
  def subscribe(subscription) do
    IO.puts("SUBSCRIBING")

    Registry.register(SubscriptionRegistry, :subscription, subscription)
  end

  def lookup() do
    IO.puts("LOOKUP")

    Registry.lookup(SubscriptionRegistry, :subscription)
  end
end

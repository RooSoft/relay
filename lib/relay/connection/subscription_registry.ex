defmodule Relay.Connection.SubscriptionRegistry do
  def subscribe(subscription) do
    Registry.register(SubscriptionRegistry, :subscription, subscription)

    subscription
  end

  def lookup() do
    Registry.lookup(SubscriptionRegistry, :subscription)
  end
end

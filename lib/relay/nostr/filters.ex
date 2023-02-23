defmodule Relay.Nostr.Filters do
  alias NostrBasics.{Filter}
  alias Relay.Nostr.Filters.Subscriptions

  def add(%Filter{subscription_id: subscription_id} = filter) do
    Registry.register(Registry.Filters, subscription_id, filter)

    Subscriptions.dispatch_added_filter(filter)

    filter
  end

  def remove_subscription(subscription_id) do
    Registry.unregister(Registry.Filters, subscription_id)

    Subscriptions.dispatch_removed_subscription(subscription_id)
  end

  def list() do
    match_pattern = {:"$1", :"$2", :"$3"}
    guards = []
    body = [{{:"$1", :"$2", :"$3"}}]
    spec = [{match_pattern, guards, body}]
    Registry.select(Registry.Filters, spec)
  end

  def count() do
    list()
    |> Enum.count()
  end
end

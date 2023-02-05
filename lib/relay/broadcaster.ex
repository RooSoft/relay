defmodule Relay.Broadcaster do
  alias Relay.Connection.{Subscription, SubscriptionRegistry}
  alias Relay.Broadcaster.Filter
  alias Relay.{Event}

  def send(%Event{} = event) do
    for {pid, subscription} <- SubscriptionRegistry.lookup() do
      if matches_subscription(event, subscription) do
        send(pid, {:emit, subscription.id, event})
      end
    end
  end

  defp matches_subscription(%Event{} = event, %Subscription{} = subscription) do
    event
    |> Filter.by_kind(subscription)
    |> Filter.by_id(subscription)
    |> Filter.by_author(subscription)
  end
end

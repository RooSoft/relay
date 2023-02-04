defmodule Relay.Broadcaster do
  alias Relay.Connection.{Subscription, SubscriptionRegistry}

  def send(event) do
    IO.inspect(event, label: "BROADCASTING")

    for {pid, subscription} <- SubscriptionRegistry.lookup() do
      if matches_subscription(event, subscription) do
        send(pid, {:emit, subscription.id, event})
      end
    end
  end

  defp matches_subscription(event, subscription) do
    event
    |> filter_by_kind(subscription)
  end

  defp filter_by_kind(%{"kind" => kind} = event, %Subscription{kinds: kinds}) do
    if Enum.member?(kinds, kind), do: event, else: nil
  end
end

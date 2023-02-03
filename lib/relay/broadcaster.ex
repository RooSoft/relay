defmodule Relay.Broadcaster do
  alias Relay.Connection.SubscriptionRegistry

  def send(event) do
    IO.inspect(event, label: "BROADCASTING")

    for {pid, subscription} <- SubscriptionRegistry.lookup() do
      send(pid, {:emit, subscription.id, event})
    end
  end
end

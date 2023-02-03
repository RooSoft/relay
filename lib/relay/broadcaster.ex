defmodule Relay.Broadcaster do
  alias Relay.Connection.SubscriptionRegistry

  def send(event) do
    IO.inspect(event, label: "BROADCASTING")

    IO.inspect(SubscriptionRegistry.lookup())
  end
end

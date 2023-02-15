defmodule Relay.Connection.FilterRegistry do
  def subscribe(filter) do
    IO.inspect(filter, label: "subscribing to")

    Registry.register(FilterRegistry, :filter, filter)

    filter
  end

  def lookup() do
    Registry.lookup(FilterRegistry, :filter)
  end
end

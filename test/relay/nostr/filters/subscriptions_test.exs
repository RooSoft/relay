defmodule Relay.Nostr.Filters.SubscriptionsTest do
  use ExUnit.Case, async: true

  alias Relay.Nostr.Filters.Subscriptions

  alias Relay.Support.Generators

  doctest Subscriptions

  test "subscribe to a new registry, send a filter to it and receive it back" do
    registry_name = Generators.Atoms.generate()
    filter = Generators.Filter.new()

    Subscriptions.init(registry: registry_name)

    Subscriptions.subscribe(registry: registry_name)

    Subscriptions.dispatch_added_filter(filter, registry: registry_name)

    self_pid = self()

    assert_receive({:added_filter, ^self_pid, ^filter}, 1000)
  end
end

defmodule Relay.Nostr.BroadcasterTest do
  use ExUnit.Case, async: true

  alias Relay.Nostr.Broadcaster

  doctest Broadcaster

  alias Relay.Nostr.Filters
  alias Relay.Support.Generators

  setup_all do
    event = Generators.Events.example()

    %{
      event: event,
      json: Jason.encode!(event)
    }
  end

  test "send an event to the current process", %{event: event, json: event_json} do
    registry_name = Generators.Registries.generate()
    filter = Generators.Filter.new(kinds: [1])

    Filters.add(filter, registry: registry_name)

    Broadcaster.send_to_all(event, registry: registry_name)

    expected_json = ~s(["EVENT","#{filter.subscription_id}",#{event_json}])

    assert_receive({:emit, ^expected_json}, 1000)
  end

  test "send EOSE to the current process" do
    Broadcaster.send_end_of_stored_events(self(), "3456-5432")

    assert_receive({:emit, ~s(["EOSE","3456-5432"])}, 1000)
  end
end

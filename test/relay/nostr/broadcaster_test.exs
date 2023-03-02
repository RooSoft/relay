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

  test "send an event to two sockets", %{event: event, json: event_json} do
    registry_name = Generators.Registries.generate()
    filter = Generators.Filter.new(kinds: [1])
    expected_json = ~s(["EVENT","#{filter.subscription_id}",#{event_json}])
    parent = self()

    for _ <- [0, 1] do
      spawn(fn ->
        Filters.add(filter, registry: registry_name)

        send(parent, :filter_added)

        assert_receive({:emit, ^expected_json}, 1000)

        send(parent, :event_received)
      end)

      receive do
        :filter_added -> :ok
      after
        1000 -> :error
      end
    end

    Broadcaster.send_to_all(event, registry: registry_name)

    assert_receive(:event_received, 1000)
    assert_receive(:event_received, 1000)
  end

  test "send an event and filter out a socket", %{event: event, json: event_json} do
    registry_name = Generators.Registries.generate()
    filters = [Generators.Filter.new(kinds: [0]), Generators.Filter.new(kinds: [1])]
    parent = self()

    for filter <- filters do
      spawn(fn ->
        Filters.add(filter, registry: registry_name)
        expected_json = ~s(["EVENT","#{filter.subscription_id}",#{event_json}])

        send(parent, :filter_added)

        case filter.kinds do
          [1] ->
            assert_receive({:emit, ^expected_json}, 1000)
            send(parent, :event_received)

          _ ->
            refute_receive({:emit, ^expected_json}, 500)
            send(parent, :no_event_received)
        end
      end)

      receive do
        :filter_added -> :ok
      after
        1000 -> :error
      end
    end

    Broadcaster.send_to_all(event, registry: registry_name)

    assert_receive(:event_received, 1000)
    assert_receive(:no_event_received, 1000)
  end

  test "send EOSE to the current process" do
    Broadcaster.send_end_of_stored_events(self(), "3456-5432")

    assert_receive({:emit, ~s(["EOSE","3456-5432"])}, 1000)
  end
end

defmodule Relay.Nostr.Connection.FiltersTest do
  use ExUnit.Case, async: true

  alias NostrBasics.{Filter}

  alias Relay.Nostr.Filters
  alias Relay.Support.Generators

  doctest Filters

  test "add a filter" do
    registry_name = Generators.Registries.generate()
    filter = Generators.Filter.new(kinds: [1])

    Filters.add(filter, registry: registry_name)

    filter_count = Filters.count(registry: registry_name)

    assert 1 == filter_count
  end

  test "add and remove a filter" do
    registry_name = Generators.Registries.generate()

    %Filter{subscription_id: subscription_id} = filter = Generators.Filter.new(kinds: [1])

    Filters.add(filter, registry: registry_name)

    assert 1 == Filters.count(registry: registry_name)

    Filters.remove_subscription(subscription_id, registry: registry_name)

    assert 0 == Filters.count(registry: registry_name)
  end

  test "add filters from another process, and verify that they're gone when the process terminate" do
    registry_name = Generators.Registries.generate()

    parent = self()

    original_filter =
      Generators.Filter.new(kinds: [1])
      |> Filters.add(registry: registry_name)

    assert 1 == Filters.count(registry: registry_name)

    spawn(fn ->
      Generators.Filter.new(kinds: [1]) |> Filters.add(registry: registry_name)
      Generators.Filter.new(kinds: [1]) |> Filters.add(registry: registry_name)

      assert 3 == Filters.count(registry: registry_name)

      send(parent, :done)
    end)

    receive do
      :done ->
        Process.sleep(10)

        assert [{original_filter.subscription_id, self(), original_filter}] ==
                 Filters.list(registry: registry_name)
    end
  end

  test "create a new registry, make sure it has no filters by default" do
    registry_name = Generators.Registries.generate()

    assert 0 == Filters.count(registry: registry_name)
  end
end

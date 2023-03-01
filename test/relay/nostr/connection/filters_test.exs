defmodule Relay.Nostr.Connection.FiltersTest do
  use ExUnit.Case, async: true

  alias NostrBasics.{Filter}

  alias Relay.Nostr.Filters
  alias Relay.Support.Generators

  doctest Filters

  test "add a filter" do
    filter = Generators.Filter.new(kinds: [1])

    Filters.add(filter)

    filter_count = Filters.count()

    assert 1 == filter_count
  end

  test "add and remove a filter" do
    original_count = Filters.count()

    %Filter{subscription_id: subscription_id} = filter = Generators.Filter.new(kinds: [1])

    Filters.add(filter)

    assert original_count + 1 == Filters.count()

    Filters.remove_subscription(subscription_id)

    assert original_count == Filters.count()
  end

  test "add filters from another process, and verify that they're gone when the process terminate" do
    parent = self()
    original_filter_count = Filters.count()
    original_filter = Generators.Filter.new(kinds: [1]) |> Filters.add()

    assert original_filter_count + 1 == Filters.count()

    spawn(fn ->
      Generators.Filter.new(kinds: [1]) |> Filters.add()
      Generators.Filter.new(kinds: [1]) |> Filters.add()

      assert original_filter_count + 3 == Filters.count()

      send(parent, :done)
    end)

    receive do
      :done ->
        Process.sleep(10)
        assert [{original_filter.subscription_id, self(), original_filter}] == Filters.list()
    end
  end

  test "create a new registry, make sure it has no filters by default" do
    registry_name = Generators.Registries.generate()

    assert 0 == Filters.count(registry: registry_name)
  end
end

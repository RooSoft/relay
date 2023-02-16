defmodule Relay.Connection.FiltersTest do
  use ExUnit.Case, async: true

  alias NostrBasics.Filter

  alias Relay.Connection.Filters
  alias Relay.Support

  doctest Filters

  test "add a filter" do
    filter = Support.FilterGenerator.new()

    Filters.add(filter)

    filter_count = Filters.count()

    assert 1 == filter_count
  end

  test "add and remove a filter" do
    %Filter{subscription_id: subscription_id} = filter = Support.FilterGenerator.new()

    Filters.add(filter)

    assert 1 == Filters.count()

    Filters.remove(subscription_id)

    assert 0 == Filters.count()
  end

  test "add filters from another process, and verify that they're gone when the process terminate" do
    parent = self()

    spawn(fn ->
      filter1 = Support.FilterGenerator.new()
      filter2 = Support.FilterGenerator.new()

      Filters.add(filter1)
      Filters.add(filter2)

      assert 2 == Filters.count()

      send(parent, :done)
    end)

    receive do
      :done ->
        Process.sleep(10)
        assert 0 == Filters.count()
    end
  end
end

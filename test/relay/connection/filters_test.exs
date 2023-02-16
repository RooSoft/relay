defmodule Relay.Connection.FiltersTest do
  use ExUnit.Case, async: true

  alias NostrBasics.{Event, Filter}

  alias Relay.Connection.Filters
  alias Relay.Support.Generators

  doctest Filters

  test "add a filter" do
    filter = Generators.Filter.new(kinds: [1])

    Filters.add(filter)

    filter_count = Filters.count()

    assert 1 == filter_count
  end

  test "add and remove a filter" do
    %Filter{subscription_id: subscription_id} = filter = Generators.Filter.new(kinds: [1])

    Filters.add(filter)

    assert 1 == Filters.count()

    Filters.remove_subscription(subscription_id)

    assert 0 == Filters.count()
  end

  test "add filters from another process, and verify that they're gone when the process terminate" do
    parent = self()

    original_filter = Generators.Filter.new(kinds: [1]) |> Filters.add()

    assert 1 == Filters.count()

    spawn(fn ->
      Generators.Filter.new(kinds: [1]) |> Filters.add()
      Generators.Filter.new(kinds: [1]) |> Filters.add()

      assert 3 == Filters.count()

      send(parent, :done)
    end)

    receive do
      :done ->
        Process.sleep(10)
        assert [{original_filter.subscription_id, self(), original_filter}] == Filters.list()
    end
  end

  test "find filters by kind" do
    Generators.Filter.new(kind: [0]) |> Filters.add()
    note_filter = Generators.Filter.new(kinds: [1]) |> Filters.add()

    note_filters =
      %Event{kind: 1}
      |> Filters.by_kind()

    subscription_id = note_filter.subscription_id
    pid = self()

    assert [{^subscription_id, ^pid, ^note_filter}] = note_filters
  end

  test "find filters by author" do
    kieran_pubkey = <<0x63FE6318DC58583CFE16810F86DD09E18BFD76AABC24A0081CE2856F330504ED::256>>

    koala_sats_pubkey =
      <<0x645681B9D067B1A362C4BEE8DDFF987D2466D49905C26CB8FEC5E6FB73AF5C84::256>>

    Generators.Filter.new(authors: [kieran_pubkey])
    |> Filters.add()

    note_filter =
      Generators.Filter.new(authors: [koala_sats_pubkey])
      |> Filters.add()

    note_filters =
      %Event{pubkey: koala_sats_pubkey}
      |> Filters.by_author()

    subscription_id = note_filter.subscription_id
    pid = self()

    assert [{^subscription_id, ^pid, ^note_filter}] = note_filters
  end
end

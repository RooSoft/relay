defmodule Relay.Connection.FiltersTest do
  use ExUnit.Case, async: true

  alias Relay.Connection.Filters
  alias Relay.Support

  doctest Filters

  test "add a filter" do
    filter = Support.FilterGenerator.new()

    Filters.add(filter)

    filter_count = Filters.count()

    assert 1 == filter_count
  end
end

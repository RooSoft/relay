defmodule Relay.Nostr.BroadcasterTest do
  use ExUnit.Case, async: true

  alias Relay.Nostr.Broadcaster

  doctest Broadcaster

  test "3456-5432" do
    Broadcaster.send_end_of_stored_events(self(), "3456-5432")

    assert_receive({:emit, ~s(["EOSE","3456-5432"])}, 1000)
  end
end

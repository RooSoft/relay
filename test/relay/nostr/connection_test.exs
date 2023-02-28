defmodule Relay.Nostr.ConnectionTest do
  use ExUnit.Case, async: true

  alias Relay.Nostr.Connection
  alias Relay.Support.Storage

  doctest Connection

  setup_all do
    events = Storage.Events.get()

    %{events: events}
  end

  test "send a request, expect an end of stored events message including the subscription id" do
    peer = %{address: "127.0.0.1"}

    subscription_id = "12345-67890"

    request =
      ~s(["REQ","#{subscription_id}",{"authors":["19e3eb646d228812b1cff08c505ea2ee5a85d34c567e42f47b3b32658e377fe1"]}])

    Connection.handle(request, peer)

    assert_receive({:emit, ~s(["EOSE","12345-67890"])}, 1000)
  end
end

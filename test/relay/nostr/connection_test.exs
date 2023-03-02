defmodule Relay.Nostr.ConnectionTest do
  use ExUnit.Case, async: true

  alias Relay.Nostr.Connection
  alias Relay.Support.Storage
  alias Relay.Support.Generators

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

  test "make a request and send an event, receive a notification" do
    peer = %{address: "127.0.0.1"}

    subscription_id = "67890-12345"

    author_request =
      ~s(["REQ","#{subscription_id}",{"authors":["efc83f01c8fb309df2c8866b8c7924cc8b6f0580afdde1d6e16e2b6107c2862c"]}])

    Connection.handle(author_request, peer)

    assert_receive({:emit, ~s(["EOSE","67890-12345"])}, 1000)

    event_json =
      Generators.Events.example()
      |> Jason.encode!()

    send_event = ~s(["EVENT",#{event_json}])

    Connection.handle(send_event, peer)

    emit_json = ~s(["EVENT","67890-12345",#{event_json}])

    assert_receive({:emit, ^emit_json}, 1000)
  end
end

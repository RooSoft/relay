defmodule Relay.Nostr.BroadcasterTest do
  use ExUnit.Case, async: true

  alias Relay.Nostr.Broadcaster

  doctest Broadcaster

  alias Relay.Nostr.Filters
  alias Relay.Support.Generators

  test "send an event to the current process" do
    registry_name = Generators.Registries.generate()
    filter = Generators.Filter.new(kinds: [1])

    Filters.add(filter, registry: registry_name)

    event = Generators.Events.example()

    Broadcaster.send_to_all(event, registry: registry_name)

    expected_json =
      ~s(["EVENT","#{filter.subscription_id}",{"content":"Making sure the schnorr signature included with notes correspond to the public key","created_at":1671985984,"id":"c87a24fc125871887a632dd069b7a510bbf987fe7210f3e5bc67492ef461d87d","kind":1,"pubkey":"efc83f01c8fb309df2c8866b8c7924cc8b6f0580afdde1d6e16e2b6107c2862c","sig":"1073eb38ba54982bf7a92139cecf23959d8cf6900ec44474bcecd9882b32f70afeadfda20620b1436f3ce9680a62261f126b92a5314fa27a4b0eab8f2447eabd","tags":[["e","4aa1f23601bb6c7275dca98bbfb6df593caeef0696f1ed260a0cb406d74d1fb0"],["e","0500f45ca79ecf3a6e4dd6ecfd6a8c2ef2fedf8c590e60b22b98196a89ee2560"],["p","98b62941fc20cfbb094e54b33593afa0090e43f263e92689a0b66b7e97cf39de"]]}])

    assert_receive({:emit, ^expected_json}, 1000)
  end

  test "send EOSE to the current process" do
    Broadcaster.send_end_of_stored_events(self(), "3456-5432")

    assert_receive({:emit, ~s(["EOSE","3456-5432"])}, 1000)
  end
end

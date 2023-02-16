defmodule Relay.Support.FilterGenerator do
  alias NostrBasics.Keys.{PrivateKey, PublicKey}

  def new do
    %NostrBasics.Filter{
      subscription_id: new_id(),
      until: nil,
      limit: nil,
      ids: [],
      authors: [
        new_public_key(),
        new_public_key(),
        new_public_key()
      ],
      kinds: [1, 42, 7, 6],
      e: [],
      p: []
    }
  end

  def new_public_key() do
    PrivateKey.create()
    |> PublicKey.from_private_key!()
  end

  defp new_id() do
    new_public_key()
    |> PublicKey.to_hex()
  end
end

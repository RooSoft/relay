defmodule Relay.Support.Generators.Values do
  alias NostrBasics.Keys.{PrivateKey, PublicKey}

  @default_id_size 16

  def public_key() do
    PrivateKey.create()
    |> PublicKey.from_private_key!()
  end

  @spec id(integer()) :: binary()
  def id(size \\ @default_id_size) do
    :crypto.strong_rand_bytes(size) |> Binary.to_hex()
  end
end

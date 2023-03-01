defmodule Relay.Support.Generators.Atoms do
  def generate(size \\ 16) do
    :crypto.strong_rand_bytes(size)
    |> Binary.to_hex()
    |> String.to_atom()
  end
end

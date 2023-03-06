defmodule Relay.Support.Generators.Values do
  alias NostrBasics.Keys.{PrivateKey, PublicKey}

  @default_id_size 16
  @default_string_size 16
  @default_number_of_list_items 16
  @alphabet Enum.concat([?0..?9, ?A..?Z, ?a..?z])

  def public_key() do
    PrivateKey.create()
    |> PublicKey.from_private_key!()
  end

  @spec id(integer()) :: binary()
  def id(size \\ @default_id_size) do
    string(size)
  end

  def string(count \\ @default_string_size) do
    # Technically not needed, but just to illustrate we're
    # relying on the PRNG for this in random/1
    :rand.seed(:exsplus, :os.timestamp())

    Stream.repeatedly(&random_char_from_alphabet/0)
    |> Enum.take(count)
    |> List.to_string()
  end

  def list(nb_items \\ @default_number_of_list_items) do
    0..(nb_items - 1)
    |> Enum.map(&string/1)
  end

  defp random_char_from_alphabet() do
    Enum.random(@alphabet)
  end
end

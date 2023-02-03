defmodule Relay.Validator do
  @moduledoc """
  Makes sure a signature is valid
  """

  alias K256.Schnorr

  @spec(check(Keyword.t()) :: :ok, {:error, message})
  def check(%{"id" => id, "pubkey" => hex_pubkey, "sig" => hex_sig}) do
    with :ok <- check_signature(id, hex_pubkey, hex_sig) do
      :ok
    else
      {:error, message} -> {:error, message}
    end
  end

  def check_signature(hex_id, hex_pubkey, hex_sig) do
    id = Binary.from_hex(hex_id)
    pubkey = Binary.from_hex(hex_pubkey)
    sig = Binary.from_hex(hex_sig)

    Schnorr.verify_message_digest(id, sig, pubkey)
  end
end

defmodule Relay.Nostr.Connection.Nip11Document do
  alias Relay.Nostr.Connection.Nip11Document
  alias Relay.Nostr.Connection.Nip11Document.Limitations

  defstruct [
    :name,
    :description,
    :pubkey,
    :contact,
    :software,
    supported_nips: [],
    limitations: %Limitations{}
  ]

  @type t :: %Nip11Document{}

  @nip11 Application.compile_env(:relay, :nip_11_document, [])

  @spec get() :: Nip11Document.t()
  def get() do
    limitations = Limitations.get()

    %Nip11Document{struct(Nip11Document, @nip11) | limitations: limitations}
  end
end

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

  @doc """
  Returns a document containing the relay's specifications

  ## Examples
      iex> Relay.Nostr.Connection.Nip11Document.get()
      %Relay.Nostr.Connection.Nip11Document{
        name: "test relay",
        description: "Built on top of the Open Telecom Platform (OTP)",
        pubkey: "5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2",
        contact: "5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2",
        supported_nips: [1, 4, 9, 11, 15],
        software: "https://github.com/RooSoft/relay.git",
        limitations: %Relay.Nostr.Connection.Nip11Document.Limitations{
          max_content_length: 1024,
          max_event_tags: 25,
          max_filters: 2,
          max_limit: 5000,
          max_message_length: 1000,
          max_subid_length: 64,
          max_subscriptions: 2
        }
      }
  """
  @spec get() :: Nip11Document.t()
  def get() do
    limitations = Limitations.get()

    %Nip11Document{struct(Nip11Document, @nip11) | limitations: limitations}
  end
end

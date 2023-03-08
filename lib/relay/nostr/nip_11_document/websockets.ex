defmodule Relay.Nostr.Nip11Document.Websockets do
  defstruct [
    :timeout,
    :keepalive
  ]

  alias Relay.Nostr.Nip11Document.Websockets

  @type t :: %Websockets{}

  @nip11 Application.compile_env(:relay, :nip_11_document, [])

  @doc """
  Returns a struct containing the relay's websockets configuration as from in the config files

  ## Examples
      iex> Relay.Nostr.Nip11Document.Websockets.get()
      %Relay.Nostr.Nip11Document.Websockets{
        timeout: 120,
        keepalive: 60
      }
  """
  @spec get() :: Websockets.t()
  def get() do
    websockets_keyword_list = Keyword.get(@nip11, :websockets, [])

    struct(Websockets, websockets_keyword_list)
  end
end

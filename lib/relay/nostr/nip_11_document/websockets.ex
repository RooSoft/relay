defmodule Relay.Nostr.Nip11Document.Websockets do
  defstruct [
    :timeout,
    :keepalive
  ]

  alias Relay.Nostr.Nip11Document.Websockets

  @type t :: %Websockets{}

  @nip11 Application.compile_env(:relay, :nip_11_document, [])

  # This thing is needed so that the Jason library knows how to serialize the events
  defimpl Jason.Encoder do
    def encode(
          %Websockets{} = websockets,
          opts
        ) do
      websockets
      |> Map.from_struct()
      |> Enum.filter(&(&1 != nil))
      |> Enum.into(%{})
      |> Jason.Encode.map(opts)
    end
  end

  @doc """
  Returns a struct containing the relay's websockets configuration as from in the config files

  ## Examples
      iex> Relay.Nostr.Nip11Document.Websockets.get()
      %Relay.Nostr.Nip11Document.Websockets{
        timeout: 120_000,
        keepalive: 60_000
      }
  """
  @spec get() :: Websockets.t()
  def get() do
    websockets_keyword_list = Keyword.get(@nip11, :websockets, [])

    struct(Websockets, websockets_keyword_list)
  end
end

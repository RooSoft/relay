defmodule Relay.Nostr.Nip11Document do
  alias Relay.Nostr.Nip11Document
  alias Relay.Nostr.Nip11Document.{Limitations, Websockets}

  defstruct [
    :name,
    :description,
    :pubkey,
    :contact,
    :software,
    :version,
    supported_nips: [],
    websockets: %Websockets{},
    limitations: %Limitations{}
  ]

  @type t :: %Nip11Document{}

  @nip11 Application.compile_env(:relay, :nip_11_document, [])

  # This thing is needed so that the Jason library knows how to serialize the events
  defimpl Jason.Encoder do
    def encode(
          %Nip11Document{} = nip11_document,
          opts
        ) do
      nip11_document
      |> Map.from_struct()
      |> Enum.filter(&(&1 != nil))
      |> Enum.into(%{})
      |> Jason.Encode.map(opts)
    end
  end

  @doc """
  Returns a document containing the relay's specifications

  ## Examples
      iex> Relay.Nostr.Nip11Document.get(version: "0.0.2")
      %Relay.Nostr.Nip11Document{
        name: "test relay",
        description: "Built on top of the Open Telecom Platform (OTP)",
        pubkey: "5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2",
        contact: "5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2",
        supported_nips: [1, 4, 9, 11, 15],
        software: "https://github.com/RooSoft/relay.git",
        version: "0.0.2",
        websockets: %Relay.Nostr.Nip11Document.Websockets{
          keepalive: 60,
          timeout: 120
        },
        limitations: %Relay.Nostr.Nip11Document.Limitations{
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
  def get(opts \\ []) do
    version = Enum.into(opts, %{}) |> Map.get(:version, get_application_version())

    websockets = Websockets.get()
    limitations = Limitations.get()

    %Nip11Document{
      struct(Nip11Document, @nip11)
      | limitations: limitations,
        websockets: websockets,
        version: version
    }
  end

  defp get_application_version do
    case :application.get_key(:relay, :vsn) do
      {:ok, version} -> to_string(version)
      _ -> "unknown"
    end
  end
end

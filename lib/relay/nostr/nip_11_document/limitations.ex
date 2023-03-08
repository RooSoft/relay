defmodule Relay.Nostr.Nip11Document.Limitations do
  defstruct [
    :max_message_length,
    :max_subscriptions,
    :max_filters,
    :max_limit,
    :max_subid_length,
    :max_event_tags,
    :max_content_length
  ]

  ## next up...
  #
  # min_prefix
  # min_pow_difficulty
  # auth_required
  # payment_required

  alias Relay.Nostr.Nip11Document.Limitations

  @type t :: %Limitations{}

  @nip11 Application.compile_env(:relay, :nip_11_document, [])

  # This thing is needed so that the Jason library knows how to serialize the events
  defimpl Jason.Encoder do
    def encode(
          %Limitations{} = limitations,
          opts
        ) do
      limitations
      |> Map.from_struct()
      |> Enum.filter(&(&1 != nil))
      |> Enum.into(%{})
      |> Jason.Encode.map(opts)
    end
  end

  @doc """
  Returns a struct containing the relay's limitations as from in the config files

  ## Examples
      iex> Relay.Nostr.Nip11Document.Limitations.get()
      %Relay.Nostr.Nip11Document.Limitations{
        max_message_length: 1000,
        max_subscriptions: 2,
        max_filters: 2,
        max_limit: 5000,
        max_subid_length: 64,
        max_event_tags: 25,
        max_content_length: 1024
      }
  """
  @spec get() :: Limitations.t()
  def get() do
    limitations_keyword_list = Keyword.get(@nip11, :limitation, [])

    struct(Limitations, limitations_keyword_list)
  end
end

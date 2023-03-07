defmodule Relay.Nostr.Connection.Nip11Document.Limitations do
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

  alias Relay.Nostr.Connection.Nip11Document.Limitations

  @nip11 Application.compile_env(:relay, :nip_11_document, [])

  def get() do
    limitations_keyword_list = Keyword.get(@nip11, :limitation)

    struct(Limitations, limitations_keyword_list)
  end
end

defimpl Inspect, for: Relay.Event do
  alias Relay.HexBinary

  def inspect(%Relay.Event{tags: raw_tags} = event, opts) do
    %{
      event
      | id: %HexBinary{data: event.id},
        pubkey: %HexBinary{data: event.pubkey},
        sig: %HexBinary{data: event.sig},
        tags: inspect_tags(raw_tags)
    }
    |> Inspect.Any.inspect(opts)
  end

  defp inspect_tags(raw_tags) do
    raw_tags
    |> Enum.map(fn [type | [raw_id | rest]] ->
      formatted_id = %HexBinary{data: raw_id}

      [type | [formatted_id | rest]]
    end)
  end
end

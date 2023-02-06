defmodule Relay.Broadcaster do
  alias Relay.Connection.{Filter, SubscriptionRegistry}
  alias Relay.Broadcaster.ApplyFilter
  alias Relay.{Event}

  def send(%Event{} = event) do
    for {pid, filter} <- SubscriptionRegistry.lookup() do
      if matches_filter(event, filter) do
        send(pid, {:emit, filter.id, event})
      end
    end
  end

  defp matches_filter(%Event{} = event, %Filter{} = filter) do
    event
    |> ApplyFilter.by_kind(filter)
    |> ApplyFilter.by_id(filter)
    |> ApplyFilter.by_author(filter)
    |> ApplyFilter.by_tags(filter)
  end
end

defmodule Relay.Broadcaster do
  alias NostrBasics.{Event, Filter}

  alias Relay.Connection.FilterRegistry
  alias Relay.Broadcaster.ApplyFilter

  def send(%Event{} = event) do
    for {pid, filter} <- FilterRegistry.lookup() do
      if matches_filter(event, filter) do
        send(pid, {:emit, filter.subscription_id, event})
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

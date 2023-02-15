defmodule Relay.Broadcaster do
  alias NostrBasics.{Event, Filter}

  alias Relay.Connection.FilterRegistry
  alias Relay.Broadcaster.ApplyFilter

  def send(%Event{} = event) do
    for {pid, filter} <- FilterRegistry.lookup() do
      if matches_filter(event, filter) do
        json = Jason.encode!(["EVENT", filter.subscription_id, event])

        send(pid, {:emit, json})
      end
    end
  end

  def send_end_of_stored_events(subscription_id) do
    subscriptions =
      FilterRegistry.lookup()
      |> Enum.filter(fn {_pid, %NostrBasics.Filter{subscription_id: filter_subscription_id}} ->
        filter_subscription_id == subscription_id
      end)

    for {pid, _filter} <- subscriptions do
      json = Jason.encode!(["EOSE", subscription_id])

      IO.inspect(json, label: "SENDING TO #{inspect(pid)}")

      send(pid, {:emit, json})
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

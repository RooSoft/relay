defmodule Relay.Nostr.Broadcaster do
  require Logger

  alias NostrBasics.{Event}

  alias Relay.Nostr.Filters
  alias Relay.Nostr.Broadcaster.ApplyFilter

  def send(%Event{} = event) do
    for {subscription_id, pid, filter} <- Filters.list() do
      if ApplyFilter.all(event, filter) do
        json = Jason.encode!(["EVENT", filter.subscription_id, event])

        Logger.info("SENDING TO #{inspect(subscription_id)} #{inspect(json)}")

        send(pid, {:emit, json})
      end
    end
  end

  def send_end_of_stored_events(pid, subscription_id) do
    json = Jason.encode!(["EOSE", subscription_id])

    send(pid, {:emit, json})
  end
end

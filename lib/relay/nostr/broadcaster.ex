defmodule Relay.Nostr.Broadcaster do
  require Logger

  alias NostrBasics.{Event}

  alias Relay.Nostr.Filters
  alias Relay.Nostr.Broadcaster.ApplyFilter

  @default_registry Registry.Filters

  @spec send_to_all(Event.t(), list()) :: list()
  def send_to_all(%Event{} = event, opts \\ []) do
    registry = Enum.into(opts, %{}) |> Map.get(:registry, @default_registry)

    for {subscription_id, pid, filter} <- Filters.list(registry: registry) do
      if ApplyFilter.all(event, filter) do
        json = Jason.encode!(["EVENT", filter.subscription_id, event])

        Logger.info("SENDING TO #{inspect(subscription_id)} #{inspect(json)}")

        send(pid, {:emit, json})
      end
    end
  end

  @spec send_end_of_stored_events(pid(), String.t()) :: {:emit, String.t()}
  def send_end_of_stored_events(pid, subscription_id) do
    json = Jason.encode!(["EOSE", subscription_id])

    send(pid, {:emit, json})
  end
end

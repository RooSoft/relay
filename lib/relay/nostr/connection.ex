defmodule Relay.Nostr.Connection do
  require Logger

  alias NostrBasics.{ClientMessage, CloseRequest, Event}
  alias NostrBasics.Event.Validator

  alias Relay.Nostr.{Broadcaster, Filters, Storage}

  def handle(request, peer) do
    request
    |> ClientMessage.parse()
    |> dispatch(peer)
  end

  defp dispatch({:event, %Event{kind: kind, content: content} = event}, peer) do
    Logger.info("#{inspect(peer.address)} sent kind #{kind}: #{inspect(content)}")

    case Validator.validate_event(event) do
      :ok ->
        event
        |> Storage.record_event()
        |> Broadcaster.send()

      {:error, message} ->
        Logger.error("VALIDATION ERROR: #{message}")
    end
  end

  defp dispatch({:req, filters}, _peer) do
    filters
    |> add_filters
    |> stream_past_events
    |> broadcast_eose
  end

  defp dispatch({:close, %CloseRequest{subscription_id: subscription_id}}, _peer) do
    Logger.debug("CLOSE COMMAND: #{inspect(subscription_id)}")

    Filters.remove_subscription(subscription_id)

    []
  end

  defp dispatch({:unknown, unknown_message}, _peer) do
    Logger.debug("UNKNOWN MESSAGE: #{inspect(unknown_message)}")

    []
  end

  def terminate(peer) do
    Logger.debug("TERMINATE: #{inspect(peer)}")
  end

  defp add_filters(filters) do
    filters
    |> Enum.each(&Filters.add/1)

    filters
  end

  defp stream_past_events(filters) when is_list(filters) do
    filters
    |> Enum.each(&stream_past_events/1)

    filters
  end

  defp stream_past_events(filter) do
    ## fetch events from an enventual database
    ## send them to pids related to that filter

    filter
  end

  defp broadcast_eose(filters) do
    filters
    |> Enum.map(&Map.get(&1, :subscription_id))
    |> Enum.uniq()
    |> Enum.each(fn subscription_id ->
      Broadcaster.send_end_of_stored_events(self(), subscription_id)
    end)

    filters
  end
end
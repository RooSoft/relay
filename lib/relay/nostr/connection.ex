defmodule Relay.Nostr.Connection do
  require Logger

  alias NostrBasics.{ClientMessage, CloseRequest, Event}

  alias Relay.Nostr.{Broadcaster, Filters, Storage}
  alias Relay.Nostr.Connection.{EventValidator, RequestValidator}

  def handle(request, peer) do
    request
    |> ClientMessage.parse()
    |> dispatch(peer)
  end

  defp dispatch({:event, %Event{kind: kind, content: content, tags: tags} = event}, peer) do
    Logger.info("#{inspect(peer.address)} sent kind #{kind}: #{inspect(content)}")

    with :ok <- EventValidator.validate_content_size(content),
         :ok <- EventValidator.validate_number_of_tags(tags),
         :ok <- Event.Validator.validate_event(event) do
      event
      |> Storage.record_event()
      |> Broadcaster.send_to_all()
    else
      {:error, message} ->
        notice = Jason.encode!(["NOTICE", message])

        send(self(), {:emit, notice})
    end
  end

  defp dispatch({:req, filters}, _peer) do
    with filters <- RequestValidator.cap_max_limit(filters),
         :ok <- RequestValidator.validate_subscription_id_length(filters),
         :ok <- RequestValidator.validate_number_of_current_subscriptions(),
         :ok <- RequestValidator.validate_number_of_filters(filters) do
      filters
      |> add_filters
      |> stream_past_events
      |> broadcast_eose
    else
      {:error, message} ->
        notice = Jason.encode!(["NOTICE", message])

        send(self(), {:emit, notice})
    end
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

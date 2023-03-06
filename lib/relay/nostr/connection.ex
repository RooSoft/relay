defmodule Relay.Nostr.Connection do
  require Logger

  alias NostrBasics.{ClientMessage, CloseRequest, Event, Filter}
  alias NostrBasics.Event.Validator

  alias Relay.Nostr.{Broadcaster, Filters, Storage}

  @max_subscription_id_byte_size 64
  @max_subscription_id_char_size @max_subscription_id_byte_size * 2
  @max_number_of_subscriptions Application.compile_env(:relay, :max_subscriptions, 10)
  @max_number_of_filters Application.compile_env(:relay, :max_filters, 10)
  @max_content_length Application.compile_env(:relay, :max_content_length, 102_400)
  @max_event_tags Application.compile_env(:relay, :max_event_tags, 2500)
  @max_limit Application.compile_env(:relay, :max_limit, 5000)

  def handle(request, peer) do
    request
    |> ClientMessage.parse()
    |> dispatch(peer)
  end

  defp dispatch({:event, %Event{kind: kind, content: content, tags: tags} = event}, peer) do
    Logger.info("#{inspect(peer.address)} sent kind #{kind}: #{inspect(content)}")

    with :ok <- validate_content_size(content),
         :ok <- validate_number_of_tags(tags),
         :ok <- Validator.validate_event(event) do
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
    ### add these tests to the with:
    ### - number of filters in the list (max 10 per subscription)

    with :ok <- validate_max_limit(filters),
         :ok <- validate_subscription_id_length(filters),
         :ok <- validate_number_of_current_subscriptions(),
         :ok <- validate_number_of_filters(filters) do
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

  defp validate_content_size(content) when byte_size(content) > @max_content_length do
    message =
      ~s(Content length of #{byte_size(content)} bytes is exceeding max length of #{@max_content_length})

    {:error, message}
  end

  defp validate_content_size(_content), do: :ok

  defp validate_number_of_tags(tags) when length(tags) > @max_event_tags do
    message =
      ~s(Event containing #{Enum.count(tags)}, exceeding the maximum of  #{@max_event_tags})

    {:error, message}
  end

  defp validate_number_of_tags(_), do: :ok

  defp validate_max_limit(filters) do
    filters
    |> Enum.map(fn %Filter{limit: limit} = filter ->
      new_limit = min(limit, @max_limit)
      %Filter{filter | limit: new_limit}
    end)

    :ok
  end

  defp validate_subscription_id_length(filters) do
    all_below_max_size? =
      filters
      |> Enum.map(& &1.subscription_id)
      |> Enum.map(&(String.length(&1) <= @max_subscription_id_char_size))
      |> Enum.all?()

    if all_below_max_size? do
      :ok
    else
      {:error, ~s(Filter subscription id size is limited to 64 bytes)}
    end
  end

  defp validate_number_of_current_subscriptions do
    subscriptions = Filters.subscriptions_by_pid()

    if Enum.count(subscriptions) >= @max_number_of_subscriptions do
      {:error, ~s(Maximum of #{@max_number_of_subscriptions} subscriptions reached)}
    else
      :ok
    end
  end

  defp validate_number_of_filters(filters) do
    if Enum.count(filters) <= @max_number_of_filters do
      :ok
    else
      {:error, ~s(Cannot add more than #{@max_number_of_filters} filters at a time)}
    end
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

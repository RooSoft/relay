defmodule Relay.Connection do
  alias NostrBasics.{ClientMessage}
  alias NostrBasics.Event.Validator

  alias Relay.{Broadcaster, Storage}
  alias Relay.Connection.FilterRegistry

  def handle(request, peer) do
    request
    |> ClientMessage.parse()
    |> dispatch(peer)
  end

  defp dispatch({:event, event}, _peer) do
    case Validator.validate_event(event) do
      :ok ->
        event
        |> Storage.record()
        |> Broadcaster.send()

      {:error, message} ->
        IO.inspect(message, label: "VALIDATION ERROR")
    end
  end

  defp dispatch({:req, filters}, _peer) do
    for filter <- filters do
      FilterRegistry.subscribe(filter)

      get_stored_events(filter)
      |> broadcast_events(filter.subscription_id)
    end
  end

  defp dispatch({:close, subscription_id}, _peer) do
    IO.inspect(subscription_id, label: "CLOSE COMMAND")

    []
  end

  defp dispatch({:unknown, unknown_message}, _peer) do
    IO.inspect(unknown_message, label: "UNKNOWN MESSAGE")

    []
  end

  def terminate(peer) do
    IO.inspect(peer, label: "TERMINATE in Relay.Request")
  end

  defp get_stored_events(_filter) do
    []
  end

  defp broadcast_events(_events, subscription_id) do
    IO.inspect(subscription_id, label: "SENDING EOS TO #{subscription_id}")
    Broadcaster.send_end_of_stored_events(subscription_id)

    :ok
  end
end

defmodule Relay.Connection do
  require Logger

  alias NostrBasics.{ClientMessage, CloseRequest}
  alias NostrBasics.Event.Validator

  alias Relay.{Broadcaster, Storage}
  alias Relay.Connection.Filters

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
        Logger.error("VALIDATION ERROR: #{message}")
    end
  end

  defp dispatch({:req, filters}, _peer) do
    for filter <- filters do
      Filters.add(filter)

      get_stored_events(filter)
      |> broadcast_events(filter.subscription_id)
    end
  end

  defp dispatch({:close, %CloseRequest{subscription_id: subscription_id}}, _peer) do
    Logger.debug("CLOSE COMMAND: #{inspect(subscription_id)}")

    []
  end

  defp dispatch({:unknown, unknown_message}, _peer) do
    Logger.debug("UNKNOWN MESSAGE: #{inspect(unknown_message)}")

    []
  end

  def terminate(peer) do
    Logger.debug("TERMINATE: #{inspect(peer)}")
  end

  defp get_stored_events(_filter) do
    []
  end

  defp broadcast_events(_events, subscription_id) do
    Logger.debug("SENDING EOS TO: #{inspect(subscription_id)}")

    Broadcaster.send_end_of_stored_events(subscription_id)

    :ok
  end
end

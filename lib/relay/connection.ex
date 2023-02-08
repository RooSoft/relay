defmodule Relay.Connection do
  alias NostrBasics.{ClientMessage}
  alias NostrBasics.Event.Validator

  alias Relay.{Broadcaster, Storage}
  alias Relay.Connection.FilterRegistry

  def handle(request, peer) do
    ClientMessage.parse(request)
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
      IO.inspect(filter, label: "ADDING A SUBSCRIPTION")
      FilterRegistry.subscribe(filter)
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
end

defmodule Relay.Nostr.Storage do
  require Logger

  def record(event) do
    Logger.debug("STORING #{inspect(event)}")

    event
  end
end

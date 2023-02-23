defmodule Relay.Nostr.Storage do
  require Logger

  alias NostrBasics.Filter

  def record_event(event) do
    Logger.debug("STORING #{inspect(event)}")

    event
  end

  def get_filtered_events(%Filter{} = _filter) do
    []
  end
end

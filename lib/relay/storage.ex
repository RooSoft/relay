defmodule Relay.Storage do
  require Logger

  def record(event) do
    Logger.debug("STORING #{inspect(event)}")
  end
end

defmodule Relay.Storage do
  require Logger

  def record(event) do
    Logger.debut("STORING #{inspect(event)}")
  end
end

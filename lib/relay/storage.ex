defmodule Relay.Storage do
  def record(event) do
    IO.inspect(event, label: "STORING")
  end
end

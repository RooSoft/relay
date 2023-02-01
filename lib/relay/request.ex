defmodule Relay.Request do
  def handle(request) do
    IO.inspect(request, label: "REQUEST in REQUEST")
  end
end

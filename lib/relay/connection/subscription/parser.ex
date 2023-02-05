defmodule Relay.Connection.Subscription.Parser do
  alias Relay.Connection.Subscription

  def from_req(query, subscription_id) do
    %Subscription{
      id: subscription_id,
      since: Map.get(query, "since"),
      until: Map.get(query, "until"),
      limit: Map.get(query, "limit"),
      ids: Map.get(query, "ids"),
      authors: get_authors(query),
      kinds: Map.get(query, "kinds"),
      e: Map.get(query, "e"),
      p: Map.get(query, "p")
    }
  end

  defp get_authors(query) do
    Map.get(query, "authors")
    |> Enum.map(&Binary.from_hex/1)
  end
end

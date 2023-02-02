defmodule Relay.Request.Subscription do
  defstruct [:id, :since, :until, :limit, ids: [], authors: [], kinds: [], e: [], p: []]

  alias Relay.Request.Subscription

  def from_req(["REQ", subscription_id, query]) do
    %Subscription{
      id: subscription_id,
      since: Map.get(query, "since"),
      until: Map.get(query, "until"),
      limit: Map.get(query, "limit"),
      ids: Map.get(query, "ids"),
      authors: Map.get(query, "authors"),
      kinds: Map.get(query, "kinds"),
      e: Map.get(query, "e"),
      p: Map.get(query, "p")
    }
  end
end

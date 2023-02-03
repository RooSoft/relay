defmodule Relay.Connection.Commands.Request do
  alias Relay.Connection.{Subscription}

  def handle([subscription_id | queries]) do
    handle_queries(subscription_id, queries)
  end

  defp handle_queries(_subscription_id, []), do: :ok

  defp handle_queries(subscription_id, [query | rest]) do
    query
    |> Subscription.from_query(subscription_id)
    |> Subscription.handle()

    handle_queries(subscription_id, rest)
  end
end

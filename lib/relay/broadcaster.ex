defmodule Relay.Broadcaster do
  alias Relay.Connection.{Subscription, SubscriptionRegistry}

  def send(event) do
    IO.inspect(event, label: "BROADCASTING")

    for {pid, subscription} <- SubscriptionRegistry.lookup() do
      if matches_subscription(event, subscription) do
        send(pid, {:emit, subscription.id, event})
      end
    end
  end

  defp matches_subscription(event, subscription) do
    event
    |> filter_by_kind(subscription)
    |> filter_by_id(subscription)
    |> filter_by_author(subscription)
  end

  defp filter_by_kind(%{"kind" => kind} = event, %Subscription{kinds: nil}), do: event

  defp filter_by_kind(%{"kind" => kind} = event, %Subscription{kinds: kinds}) do
    if Enum.member?(kinds, kind), do: event, else: nil
  end

  defp filter_by_id(%{"kind" => kind} = event, %Subscription{ids: nil}), do: event

  defp filter_by_id(%{"kind" => id} = event, %Subscription{ids: ids}) do
    if Enum.member?(ids, id), do: event, else: nil
  end

  defp filter_by_author(%{"pubkey" => author} = event, %Subscription{authors: nil}), do: event

  defp filter_by_author(%{"pubkey" => author} = event, %Subscription{authors: authors}) do
    IO.inspect(authors)
    IO.inspect(author)

    if Enum.member?(authors, author), do: event, else: nil
  end
end

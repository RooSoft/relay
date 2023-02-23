defmodule Relay.Nostr.Filters.Subscriptions do
  def init() do
    Registry.start_link(keys: :unique, name: Registry.FilterSubscribers)
  end

  def subscribe() do
    Registry.register(Registry.FilterSubscribers, self(), self())
  end

  def unsubscribe() do
    Registry.unregister(Registry.FilterSubscribers, self())
  end

  def dispatch_added_filter(filter) do
    dispatch({:added_filter, self(), filter})
  end

  def dispatch_removed_subscription(subscription_id) do
    dispatch({:removed_subscription, self(), subscription_id})
  end

  defp dispatch(message) do
    for pid <- get_all_filter_subscriber_pids() do
      send(pid, message)
    end
  end

  defp get_all_filter_subscriber_pids() do
    match_pattern = {:_, :"$1", :_}
    guards = []
    body = [{{:"$1"}}]
    spec = [{match_pattern, guards, body}]

    Registry.select(Registry.FilterSubscribers, spec)
    |> Enum.map(fn {pid} -> pid end)
    |> Enum.uniq()
  end
end

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

  def dispatch(filter, title) do
    for pid <- get_all_filter_subscriber_pids() do
      send(pid, {title, filter})
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

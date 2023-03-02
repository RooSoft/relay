defmodule Relay.Nostr.Filters.Subscriptions do
  @default_registry Registry.FilterSubscribers

  def init(opts \\ []) do
    registry = Enum.into(opts, %{}) |> Map.get(:registry, @default_registry)

    Registry.start_link(keys: :unique, name: registry)
  end

  def subscribe(opts \\ []) do
    registry = Enum.into(opts, %{}) |> Map.get(:registry, @default_registry)

    Registry.register(registry, self(), self())
  end

  def unsubscribe(opts \\ []) do
    registry = Enum.into(opts, %{}) |> Map.get(:registry, @default_registry)

    Registry.unregister(registry, self())
  end

  def dispatch_added_filter(filter, opts \\ []) do
    registry = Enum.into(opts, %{}) |> Map.get(:registry, @default_registry)

    dispatch({:added_filter, self(), filter}, registry)
  end

  def dispatch_removed_subscription(subscription_id, opts \\ []) do
    registry = Enum.into(opts, %{}) |> Map.get(:registry, @default_registry)

    dispatch({:removed_subscription, self(), subscription_id}, registry)
  end

  defp dispatch(message, registry) do
    for pid <- get_all_filter_subscriber_pids(registry) do
      send(pid, message)
    end
  end

  defp get_all_filter_subscriber_pids(registry) do
    match_pattern = {:_, :"$1", :_}
    guards = []
    body = [{{:"$1"}}]
    spec = [{match_pattern, guards, body}]

    Registry.select(registry, spec)
    |> Enum.map(fn {pid} -> pid end)
    |> Enum.uniq()
  end
end

defmodule Relay.Nostr.Filters do
  @moduledoc """
  Keeps a list of filters indexed by socket PID, and makes sure to drop them
  when the socket closes.
  """

  alias NostrBasics.{Filter}
  alias Relay.Nostr.Filters.Subscriptions

  @default_registry Registry.Filters

  @doc """
  Add a filter to the list

  ## Examples

      iex> ~s({"kinds":[1],"limit":10})
      ...> |> NostrBasics.Filter.from_req!("a_subscription_id")
      ...> |> Relay.Nostr.Filters.add()
      %NostrBasics.Filter{
        subscription_id: "a_subscription_id",
        limit: 10,
        kinds: [1]
      }
  """
  @spec add(Filter.t(), list()) :: Filter.t()
  def add(%Filter{subscription_id: subscription_id} = filter, opts \\ []) do
    registry = Enum.into(opts, %{}) |> Map.get(:registry, @default_registry)

    Registry.register(registry, subscription_id, filter)

    Subscriptions.dispatch_added_filter(filter)

    filter
  end

  @doc """
  Removes a subscription to the list

  ## Examples

      iex> Relay.Nostr.Filters.remove_subscription("a_subscription_id")
  """
  @spec remove_subscription(String.t(), list()) :: list()
  def remove_subscription(subscription_id, opts \\ []) do
    registry = Enum.into(opts, %{}) |> Map.get(:registry, @default_registry)

    Registry.unregister(registry, subscription_id)

    Subscriptions.dispatch_removed_subscription(subscription_id)
  end

  @doc """
  Returns all the filters in a tuple also containing the subscription id and the pid

  ## Examples

      iex> registry_name = Relay.Support.Generators.Registries.generate()
      ...> Relay.Nostr.Filters.list(registry: registry_name)
      []
  """
  @spec list(list()) :: list()
  def list(opts \\ []) do
    registry = Enum.into(opts, %{}) |> Map.get(:registry, @default_registry)

    match_pattern = {:"$1", :"$2", :"$3"}
    guards = []
    body = [{{:"$1", :"$2", :"$3"}}]
    spec = [{match_pattern, guards, body}]
    Registry.select(registry, spec)
  end

  @doc """
  Returns a count of all the filters

  ## Examples

      iex> Relay.Nostr.Filters.count()
  """
  @spec count(list()) :: integer()
  def count(opts \\ []) do
    list(opts)
    |> Enum.count()
  end
end

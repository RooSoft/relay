defmodule Relay.Nostr.Filters do
  @moduledoc """
  Keeps a list of filters indexed by socket PID, and makes sure to drop them
  when the socket closes.
  """

  alias NostrBasics.{Filter}
  alias Relay.Nostr.Filters.Subscriptions

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
  @spec add(Filter.t()) :: Filter.t()
  def add(%Filter{subscription_id: subscription_id} = filter) do
    Registry.register(Registry.Filters, subscription_id, filter)

    Subscriptions.dispatch_added_filter(filter)

    filter
  end

  @doc """
  Removes a subscription to the list

  ## Examples

      iex> Relay.Nostr.Filters.remove_subscription("a_subscription_id")
  """
  @spec remove_subscription(String.t()) :: list()
  def remove_subscription(subscription_id) do
    Registry.unregister(Registry.Filters, subscription_id)

    Subscriptions.dispatch_removed_subscription(subscription_id)
  end

  @doc """
  Returns all the filters in a tuple also containing the subscription id and the pid

  ## Examples

      iex> Relay.Nostr.Filters.list()
      []
  """
  @spec list() :: list()
  def list() do
    match_pattern = {:"$1", :"$2", :"$3"}
    guards = []
    body = [{{:"$1", :"$2", :"$3"}}]
    spec = [{match_pattern, guards, body}]
    Registry.select(Registry.Filters, spec)
  end

  def count() do
    list()
    |> Enum.count()
  end
end

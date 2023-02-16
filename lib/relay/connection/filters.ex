defmodule Relay.Connection.Filters do
  alias NostrBasics.Filter

  def add(%Filter{subscription_id: subscription_id} = filter) do
    Registry.register(Registry.Filters, subscription_id, filter)

    filter
  end

  def remove_subscription(subscription_id) do
    Registry.unregister(Registry.Filters, subscription_id)
  end

  def list() do
    match_pattern = {:"$1", :"$2", :"$3"}
    guards = []
    body = [{{:"$1", :"$2", :"$3"}}]
    spec = [{match_pattern, guards, body}]
    Registry.select(Registry.Filters, spec)
  end

  def by_kind(kind) do
    list()
    |> Enum.filter(fn {_subscription_id, _pid, %Filter{} = f} ->
      Enum.member?(f.kinds, kind)
    end)
  end

  def count() do
    list()
    |> Enum.count()
  end
end

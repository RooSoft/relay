defmodule Relay.Broadcaster.Filter do
  @moduledoc """
  Makes sure an event matches a subscription
  """

  alias Relay.Connection.Subscription

  def by_id(%{"id" => _kind} = event, %Subscription{ids: nil}), do: event

  def by_id(%{"id" => id} = event, %Subscription{ids: ids}) do
    if Enum.member?(ids, id), do: event, else: nil
  end

  def by_author(%{"pubkey" => _author} = event, %Subscription{authors: nil}), do: event

  def by_author(%{"pubkey" => author} = event, %Subscription{authors: authors}) do
    if Enum.member?(authors, author), do: event, else: nil
  end

  def by_kind(%{"kind" => _kind} = event, %Subscription{kinds: nil}), do: event

  def by_kind(%{"kind" => kind} = event, %Subscription{kinds: kinds}) do
    if Enum.member?(kinds, kind), do: event, else: nil
  end
end

defmodule Relay.Broadcaster.Filter do
  @moduledoc """
  Makes sure an event matches a subscription
  """

  alias Relay.Event
  alias Relay.Connection.Subscription

  def by_id(%Event{id: _kind} = event, %Subscription{ids: nil}), do: event

  def by_id(%Event{id: id} = event, %Subscription{ids: ids}) do
    if Enum.member?(ids, id), do: event, else: nil
  end

  def by_author(%Event{pubkey: _author} = event, %Subscription{authors: nil}), do: event

  def by_author(%Event{pubkey: author} = event, %Subscription{authors: authors}) do
    if Enum.member?(authors, author), do: event, else: nil
  end

  def by_kind(%Event{kind: _kind} = event, %Subscription{kinds: nil}), do: event

  def by_kind(%Event{kind: kind} = event, %Subscription{kinds: kinds}) do
    if Enum.member?(kinds, kind), do: event, else: nil
  end
end

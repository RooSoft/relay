defmodule Relay.Broadcaster.Filter do
  @moduledoc """
  Makes sure an event matches a subscription
  """

  alias Relay.Event
  alias Relay.Connection.Subscription

  def by_id(nil, _), do: nil
  def by_id(%Event{id: _kind} = event, %Subscription{ids: nil}), do: event

  def by_id(%Event{id: id} = event, %Subscription{ids: ids}) do
    if Enum.member?(ids, id), do: event, else: nil
  end

  def by_author(nil, _), do: nil
  def by_author(%Event{pubkey: _author} = event, %Subscription{authors: nil}), do: event

  def by_author(%Event{pubkey: author} = event, %Subscription{authors: authors}) do
    if Enum.member?(authors, author), do: event, else: nil
  end

  def by_kind(nil, _), do: nil
  def by_kind(%Event{kind: _kind} = event, %Subscription{kinds: nil}), do: event

  def by_kind(%Event{kind: kind} = event, %Subscription{kinds: kinds}) do
    if Enum.member?(kinds, kind), do: event, else: nil
  end

  def by_tags(nil, _), do: nil

  def by_tags(%Event{tags: tags} = event, %Subscription{e: e, p: p}) do
    is_match =
      tags
      |> Enum.any?(fn [type | [id | _rest]] ->
        case type do
          "e" -> Enum.member?(e, id)
          "p" -> Enum.member?(p, id)
        end
      end)

    case is_match do
      true -> event
      false -> nil
    end
  end
end

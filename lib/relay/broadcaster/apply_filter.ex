defmodule Relay.Broadcaster.ApplyFilter do
  @moduledoc """
  Makes sure an event matches a filter
  """

  alias Relay.Event
  alias Relay.Connection.Filter

  def by_id(nil, _), do: nil
  def by_id(%Event{id: _kind} = event, %Filter{ids: nil}), do: event

  def by_id(%Event{id: id} = event, %Filter{ids: ids}) do
    if Enum.member?(ids, id), do: event, else: nil
  end

  def by_author(nil, _), do: nil
  def by_author(%Event{pubkey: _author} = event, %Filter{authors: nil}), do: event

  def by_author(%Event{pubkey: author} = event, %Filter{authors: authors}) do
    if Enum.member?(authors, author), do: event, else: nil
  end

  def by_kind(nil, _), do: nil
  def by_kind(%Event{kind: _kind} = event, %Filter{kinds: nil}), do: event

  def by_kind(%Event{kind: kind} = event, %Filter{kinds: kinds}) do
    if Enum.member?(kinds, kind), do: event, else: nil
  end

  def by_tags(nil, _), do: nil
  def by_tags(%Event{tags: _kind} = event, %Filter{e: nil, p: nil}), do: event

  def by_tags(%Event{tags: tags} = event, %Filter{e: e, p: p}) do
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

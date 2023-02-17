defmodule Relay.Broadcaster.ApplyFilter do
  @moduledoc """
  Makes sure an event matches a filter
  """

  alias NostrBasics.{Event, Filter}

  @doc """
  Applies a ID filter to an event

  ## Examples
      iex> id = "cabf522ac94121ffc04a07265960fc5e"
      ...> filter = %NostrBasics.Filter{ids: [id]}
      ...> event = %NostrBasics.Event{id: id}
      ...> Relay.Broadcaster.ApplyFilter.by_id(event, filter)
      event

      iex> id = "cabf522ac94121ffc04a07265960fc5e"
      ...> filter = %NostrBasics.Filter{ids: [id]}
      ...> event = %NostrBasics.Event{id: String.reverse(id)}
      ...> Relay.Broadcaster.ApplyFilter.by_id(event, filter)
      nil
  """
  def by_id(nil, _), do: nil
  def by_id(%Event{id: _kind} = event, %Filter{ids: nil}), do: event
  def by_id(%Event{id: _kind} = event, %Filter{ids: []}), do: event

  def by_id(%Event{id: id} = event, %Filter{ids: ids}) do
    if Enum.member?(ids, id), do: event, else: nil
  end

  @doc """
  Applies a author filter to an event, applied on the pubkey

  ## Examples
      iex> author = <<0xee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74::256>>
      ...> filter = %NostrBasics.Filter{authors: [author]}
      ...> event = %NostrBasics.Event{pubkey: author}
      ...> Relay.Broadcaster.ApplyFilter.by_author(event, filter)
      event

      iex> author = <<0xee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74::256>>
      ...> filter = %NostrBasics.Filter{authors: [author]}
      ...> event = %NostrBasics.Event{pubkey: Binary.reverse(author)}
      ...> Relay.Broadcaster.ApplyFilter.by_author(event, filter)
      nil
  """
  def by_author(nil, _), do: nil
  def by_author(%Event{pubkey: _author} = event, %Filter{authors: nil}), do: event
  def by_author(%Event{pubkey: _author} = event, %Filter{authors: []}), do: event

  def by_author(%Event{pubkey: author} = event, %Filter{authors: authors}) do
    if Enum.member?(authors, author), do: event, else: nil
  end

  @doc """
  Applies a kind filter to an event

  ## Examples
      iex> kind = 1
      ...> filter = %NostrBasics.Filter{kinds: [kind]}
      ...> event = %NostrBasics.Event{kind: kind}
      ...> Relay.Broadcaster.ApplyFilter.by_kind(event, filter)
      event

      iex> kind = 1
      ...> filter = %NostrBasics.Filter{kinds: [kind]}
      ...> event = %NostrBasics.Event{kind: kind+1}
      ...> Relay.Broadcaster.ApplyFilter.by_kind(event, filter)
      nil
  """
  def by_kind(nil, _), do: nil
  def by_kind(%Event{kind: _kind} = event, %Filter{kinds: nil}), do: event
  def by_kind(%Event{kind: _kind} = event, %Filter{kinds: []}), do: event

  def by_kind(%Event{kind: kind} = event, %Filter{kinds: kinds}) do
    if Enum.member?(kinds, kind), do: event, else: nil
  end

  @doc """
  Applies a event tag filter to an event

  ## Examples
      iex> event_id = "ee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74"
      ...> filter = %NostrBasics.Filter{e: [event_id]}
      ...> e_tag = ["e", event_id, ""]
      ...> event = %NostrBasics.Event{tags: [e_tag]}
      ...> Relay.Broadcaster.ApplyFilter.by_event_tag(event, filter)
      event

      iex> event_id = "ee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74"
      ...> filter = %NostrBasics.Filter{e: [event_id]}
      ...> event = %NostrBasics.Event{tags: []}
      ...> Relay.Broadcaster.ApplyFilter.by_event_tag(event, filter)
      nil
  """
  def by_event_tag(nil, _), do: nil
  def by_event_tag(%Event{tags: _kind} = event, %Filter{e: []}), do: event

  def by_event_tag(%Event{tags: tags} = event, %Filter{e: e}) do
    is_match =
      tags
      |> Enum.any?(fn [type | [id | _rest]] ->
        case type do
          "e" -> Enum.member?(e, id)
        end
      end)

    case is_match do
      true -> event
      false -> nil
    end
  end
end

defmodule Relay.Nostr.Broadcaster.ApplyFilter do
  @moduledoc """
  Makes sure an event matches a filter
  """

  alias NostrBasics.{Event, Filter}

  @doc """
  Applies all filters to an event and see if it gets returned

  ## Examples
      iex> id = "cabf522ac94121ffc04a07265960fc5e"
      ...> author = <<0xee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74::256>>
      ...> kind = 1
      ...> filter = %NostrBasics.Filter{ids: [id], authors: [author], kinds: [kind]}
      ...> event = %NostrBasics.Event{id: id, pubkey: author, kind: kind}
      ...> |> Relay.Nostr.Broadcaster.ApplyFilter.all(filter)
      event
  """
  @spec all(Event.t(), Filter.t()) :: Event.t() | nil
  def all(%Event{} = event, %Filter{} = filter) do
    event
    |> by_kind(filter)
    |> by_id(filter)
    |> by_author(filter)
    |> by_event_tag(filter)
    |> by_person_tag(filter)
  end

  @doc """
  Applies a ID filter to an event

  ## Examples
      iex> id = <<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>
      ...> filter = %NostrBasics.Filter{ids: [id]}
      ...> event = %NostrBasics.Event{id: id}
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_id(event, filter)
      event

      iex> id = <<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>
      ...> <<prefix::bitstring-size(32), _::bitstring>> = id
      ...> filter = %NostrBasics.Filter{ids: [prefix]}
      ...> event = %NostrBasics.Event{id: id}
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_id(event, filter)
      event

      iex> id = <<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>
      ...> filter = %NostrBasics.Filter{ids: [id]}
      ...> event = %NostrBasics.Event{id: String.reverse(id)}
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_id(event, filter)
      nil
  """
  def by_id(nil, _), do: nil
  def by_id(%Event{id: _kind} = event, %Filter{ids: nil}), do: event
  def by_id(%Event{id: _kind} = event, %Filter{ids: []}), do: event

  def by_id(%Event{id: id} = event, %Filter{ids: ids}) do
    found =
      ids
      |> Enum.any?(fn filter_id ->
        filter_id_size = bit_size(filter_id)

        case id do
          ^filter_id -> true
          <<^filter_id::bitstring-size(filter_id_size), _::bitstring>> -> true
          _ -> false
        end
      end)

    if found, do: event, else: nil
  end

  @doc """
  Applies a author filter to an event, applied on the pubkey

  ## Examples
      iex> author = <<0xee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74::256>>
      ...> filter = %NostrBasics.Filter{authors: [author]}
      ...> event = %NostrBasics.Event{pubkey: author}
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_author(event, filter)
      event

      iex> author = <<0xee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74::256>>
      ...> filter = %NostrBasics.Filter{authors: [author]}
      ...> event = %NostrBasics.Event{pubkey: Binary.reverse(author)}
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_author(event, filter)
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
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_kind(event, filter)
      event

      iex> kind = 1
      ...> filter = %NostrBasics.Filter{kinds: [kind]}
      ...> event = %NostrBasics.Event{kind: kind+1}
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_kind(event, filter)
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
      #### applying filtering with the same event id, should be pass
      iex> event_id = "ee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74"
      ...> filter = %NostrBasics.Filter{e: [event_id]}
      ...> e_tag = ["e", event_id, ""]
      ...> event = %NostrBasics.Event{tags: [e_tag]}
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_event_tag(event, filter)
      event

      #### applying filtering on an event with no tag, should be filtered out
      iex> event_id = "ee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74"
      ...> filter = %NostrBasics.Filter{e: [event_id]}
      ...> event = %NostrBasics.Event{tags: []}
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_event_tag(event, filter)
      nil

      #### applying filtering with an empty event tag, should pass
      iex> event_id = "ee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74"
      ...> filter = %NostrBasics.Filter{e: []}
      ...> event = %NostrBasics.Event{tags: [event_id]}
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_event_tag(event, filter)
      event

      #### filtering for an event list the event is not a part of, should be filtered out
      iex> event_id = "ee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74"
      ...> wrong_event_id_1 = "c48389c1ba5a8b38da3ff7f3bb2c6cdee09f962d6155b784e6ee43a2829fa224"
      ...> wrong_event_id_2 = "343d863778954b3a0ed65567212358c9ef6b4a24393610cf7e4e3e71bc559027"
      ...> filter = %NostrBasics.Filter{e: [wrong_event_id_1, wrong_event_id_2]}
      ...> e_tag = ["e", event_id, ""]
      ...> event = %NostrBasics.Event{tags: [e_tag]}
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_event_tag(event, filter)
      nil

      #### filtering for an event list the event is a part of, should pass
      iex> event_id = "ee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74"
      ...> wrong_event_id_1 = "c48389c1ba5a8b38da3ff7f3bb2c6cdee09f962d6155b784e6ee43a2829fa224"
      ...> wrong_event_id_2 = "343d863778954b3a0ed65567212358c9ef6b4a24393610cf7e4e3e71bc559027"
      ...> filter = %NostrBasics.Filter{e: [wrong_event_id_1, event_id, wrong_event_id_2]}
      ...> e_tag = ["e", event_id, ""]
      ...> event = %NostrBasics.Event{tags: [e_tag]}
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_event_tag(event, filter)
      event
  """
  def by_event_tag(nil, _), do: nil
  def by_event_tag(%Event{tags: _kind} = event, %Filter{e: []}), do: event

  def by_event_tag(%Event{} = event, %Filter{e: filter_tag_list}) do
    match_tag("e", event, filter_tag_list)
    |> maybe_return_event(event)
  end

  @doc """
  Applies a person tag filter to an event

  ## Examples
      #### applying filtering with the same pubkey, should be pass
      iex> pubkey = "ee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74"
      ...> filter = %NostrBasics.Filter{p: [pubkey]}
      ...> p_tag = ["p", pubkey, ""]
      ...> event = %NostrBasics.Event{tags: [p_tag]}
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_person_tag(event, filter)
      event

      #### applying a filter on an event with no tag, should be filtered out
      iex> pubkey = "ee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74"
      ...> filter = %NostrBasics.Filter{p: [pubkey]}
      ...> event = %NostrBasics.Event{tags: []}
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_person_tag(event, filter)
      nil

      #### applying filtering with an empty person tag, should pass
      iex> pubkey = "ee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74"
      ...> filter = %NostrBasics.Filter{p: []}
      ...> event = %NostrBasics.Event{tags: [pubkey]}
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_person_tag(event, filter)
      event

      #### filtering for an event list the event is not a part of, should be filtered out
      iex> pubkey = "ee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74"
      ...> wrong_pubkey_1 = "c48389c1ba5a8b38da3ff7f3bb2c6cdee09f962d6155b784e6ee43a2829fa224"
      ...> wrong_pubkey_2 = "343d863778954b3a0ed65567212358c9ef6b4a24393610cf7e4e3e71bc559027"
      ...> filter = %NostrBasics.Filter{p: [wrong_pubkey_1, wrong_pubkey_2]}
      ...> p_tag = ["p", pubkey, ""]
      ...> event = %NostrBasics.Event{tags: [p_tag]}
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_person_tag(event, filter)
      nil

      #### filtering for an event list the event is a part of, should pass
      iex> pubkey = "ee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74"
      ...> wrong_pubkey_1 = "c48389c1ba5a8b38da3ff7f3bb2c6cdee09f962d6155b784e6ee43a2829fa224"
      ...> wrong_pubkey_2 = "343d863778954b3a0ed65567212358c9ef6b4a24393610cf7e4e3e71bc559027"
      ...> filter = %NostrBasics.Filter{p: [wrong_pubkey_1, pubkey, wrong_pubkey_2]}
      ...> p_tag = ["p", pubkey, ""]
      ...> event = %NostrBasics.Event{tags: [p_tag]}
      ...> Relay.Nostr.Broadcaster.ApplyFilter.by_event_tag(event, filter)
      event
  """
  def by_person_tag(nil, _), do: nil
  def by_person_tag(%Event{tags: _kind} = event, %Filter{p: []}), do: event

  def by_person_tag(%Event{} = event, %Filter{p: filter_tag_list}) do
    match_tag("p", event, filter_tag_list)
    |> maybe_return_event(event)
  end

  defp match_tag(tag_type, %Event{tags: tags}, filter_tag_list) do
    tags
    |> Enum.any?(fn [type | [id | _rest]] ->
      case type do
        ^tag_type -> Enum.member?(filter_tag_list, id)
        _ -> false
      end
    end)
  end

  defp maybe_return_event(true, event), do: event
  defp maybe_return_event(false, _event), do: nil
end

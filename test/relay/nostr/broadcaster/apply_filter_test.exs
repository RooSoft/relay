defmodule Relay.Nostr.Broadcaster.ApplyFilterTest do
  use ExUnit.Case, async: true

  alias NostrBasics.{Event, Filter}

  alias Relay.Nostr.Broadcaster.ApplyFilter
  alias Relay.Support.Storage

  @note_kind 1
  @reaction_kind 7

  doctest ApplyFilter

  setup_all do
    events = Storage.Events.get()
    notes = Storage.Events.get_notes(events)
    reactions = Storage.Events.get_reactions(events)

    %{events: events, notes: notes, reactions: reactions}
  end

  test "same as a doctest, easier to debug from here" do
    pubkey = "ee6ea13ab9fe5c4a68eaf9b1a34fe014a66b40117c50ee2a614f4cda959b6e74"
    wrong_pubkey_1 = "c48389c1ba5a8b38da3ff7f3bb2c6cdee09f962d6155b784e6ee43a2829fa224"
    wrong_pubkey_2 = "343d863778954b3a0ed65567212358c9ef6b4a24393610cf7e4e3e71bc559027"

    filter = %Filter{p: [wrong_pubkey_1, wrong_pubkey_2]}

    p_tag = ["p", pubkey, ""]
    event = %Event{tags: [p_tag]}

    filter_result = ApplyFilter.by_person_tag(event, filter)

    assert nil == filter_result
  end

  test "filter a notes list with kind 1, make sure none gets filtered out", %{notes: notes} do
    same_notes =
      notes
      |> Enum.map(&ApplyFilter.all(&1, %Filter{kinds: [@note_kind]}))
      |> Enum.filter(&(&1 != nil))

    assert notes == same_notes
  end

  test "filter a notes list with kind 7, make sure they all get filtered out", %{notes: notes} do
    nothing =
      notes
      |> Enum.map(&ApplyFilter.all(&1, %Filter{kinds: [@reaction_kind]}))
      |> Enum.filter(&(&1 != nil))

    assert [] == nothing
  end

  test "filter event for notes from a specific poster", %{events: events} do
    author_s_notes =
      events
      |> Enum.map(
        &ApplyFilter.all(&1, %Filter{
          kinds: [@note_kind],
          authors: [<<0x237506CA399E5B1B9CE89455FE960BC98DFAB6A71936772A89C5145720B681F4::256>>]
        })
      )
      |> Enum.filter(&(&1 != nil))
      |> Enum.map(& &1.content)

    assert [
             "New ‘Universe 🛸’ (global) is a game changer",
             "Can’t zap until tomorrow morning … 🥱"
           ] == author_s_notes
  end
end

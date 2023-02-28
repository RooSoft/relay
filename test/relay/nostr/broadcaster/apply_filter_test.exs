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

  test "filter events for notes from a specific poster", %{events: events} do
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

  test "filter events for reactions with specific person in tags", %{events: events} do
    events_with_p_tags =
      events
      |> Enum.map(
        &ApplyFilter.all(&1, %Filter{
          kinds: [@reaction_kind],
          p: ["7fa56f5d6962ab1e3cd424e758c3002b8665f7b0d8dcee9fe9e288d7751ac194"]
        })
      )
      |> Enum.filter(&(&1 != nil))
      |> Enum.map(& &1.content)

    assert ["+", "+", "🤙", "+", "🤙"] == events_with_p_tags
  end

  test "filter events for replys to a specific note", %{events: events} do
    events_with_e_tags =
      events
      |> Enum.map(
        &ApplyFilter.all(&1, %Filter{
          kinds: [@note_kind],
          e: ["5109e7498e879d7962ba8cc867a5815da99ac38eb0f732970b93a23384c4a8df"]
        })
      )
      |> Enum.filter(&(&1 != nil))
      |> Enum.map(& &1.content)

    assert [
             "Must be a techy guy with cables hanging out of his pockets😄",
             "🤣🤣🤣"
           ] ==
             events_with_e_tags
  end

  test "filter events by ids", %{events: events} do
    filtered_events =
      events
      |> Enum.map(
        &ApplyFilter.all(&1, %Filter{
          ids: [
            "fd8cf79316c7058e14f400725481a4e29689d87bdf83508c2ef75cb896a61a7d",
            "5109e7498e879d7962ba8cc867a5815da99ac38eb0f732970b93a23384c4a8df"
          ]
        })
      )
      |> Enum.filter(&(&1 != nil))
      |> Enum.map(& &1.id)

    assert [
             "5109e7498e879d7962ba8cc867a5815da99ac38eb0f732970b93a23384c4a8df",
             "fd8cf79316c7058e14f400725481a4e29689d87bdf83508c2ef75cb896a61a7d"
           ] ==
             filtered_events
  end

  test "filter events with two person tags, one of them should come out", %{events: events} do
    filtered_events =
      events
      |> Enum.map(
        &ApplyFilter.all(&1, %Filter{
          kinds: [1, 7],
          p: [
            "be440b434f2c0b6df2ec4e5137bc9c2bd8dae9fe530255eaee3accbf204e818e",
            "056d6999f3283778d50aa85c25985716857cfeaffdbad92e73cf8aeaf394a5cd"
          ]
        })
      )
      |> Enum.filter(&(&1 != nil))
      |> Enum.map(& &1.id)

    assert ["fd8cf79316c7058e14f400725481a4e29689d87bdf83508c2ef75cb896a61a7d"] == filtered_events
  end
end

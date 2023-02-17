defmodule Relay.Broadcaster.ApplyFilterTest do
  use ExUnit.Case, async: true

  alias NostrBasics.{Event, Filter}
  alias Relay.Broadcaster.ApplyFilter

  doctest ApplyFilter

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
end

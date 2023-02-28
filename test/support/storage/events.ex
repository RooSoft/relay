defmodule Relay.Support.Storage.Events do
  def get do
    File.stream!("test/support/data/notes.json")
    |> Stream.map(&NostrBasics.Event.parse!/1)
    |> Enum.to_list()
  end

  def get_notes do
    get()
    |> Stream.filter(&(&1.kind == 1))
    |> Enum.to_list()
  end

  def get_notes(events) do
    events
    |> Enum.filter(&(&1.kind == 1))
  end

  def get_reactions do
    get()
    |> Stream.filter(&(&1.kind == 7))
    |> Enum.to_list()
  end

  def get_reactions(events) do
    events
    |> Enum.filter(&(&1.kind == 7))
  end
end

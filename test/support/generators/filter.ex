defmodule Relay.Support.Generators.Filter do
  alias Relay.Support.Generators.Values

  @default_kinds []
  @default_authors []

  def new(opts \\ []) do
    kinds = Keyword.get(opts, :kinds, @default_kinds)
    authors = Keyword.get(opts, :authors, @default_authors)

    %NostrBasics.Filter{
      subscription_id: Values.id(),
      ids: [],
      authors: authors,
      kinds: kinds,
      e: [],
      p: []
    }
  end
end

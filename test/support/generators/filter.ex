defmodule Relay.Support.Generators.Filter do
  alias Relay.Support.Generators.Values

  @default_kinds []
  @default_authors []
  @default_number_of_filters 10

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

  def list(number_of_filters \\ @default_number_of_filters) do
    for _ <- 0..(number_of_filters - 1) do
      new()
    end
  end
end

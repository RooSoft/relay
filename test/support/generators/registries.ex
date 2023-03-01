defmodule Relay.Support.Generators.Registries do
  alias Relay.Support.Generators

  def generate() do
    name = Generators.Atoms.generate()

    Registry.start_link(keys: :duplicate, name: name)

    name
  end
end

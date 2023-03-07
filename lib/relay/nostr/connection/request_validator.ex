defmodule Relay.Nostr.Connection.RequestValidator do
  @moduledoc """
  Request valdation to make sure it respects sane maximum defaults
  """

  alias NostrBasics.Filter

  alias Relay.Nostr.{Filters}

  @default_filters_registry Registry.Filters

  @max_subid_length Application.compile_env(:relay, :max_subid_length, 256)
  @max_number_of_subscriptions Application.compile_env(:relay, :max_subscriptions, 10)
  @max_number_of_filters Application.compile_env(:relay, :max_filters, 10)
  @max_limit Application.compile_env(:relay, :max_limit, 5000)

  @doc """
  Cap the number of requested events according to the maximum in the configuration settings

  ## Examples
      iex> filter = Relay.Support.Generators.Filter.new()
      ...> [%NostrBasics.Filter{filter | limit: 10}, %NostrBasics.Filter{filter | limit: 5001}]
      ...> |> Relay.Nostr.Connection.RequestValidator.cap_max_limit()
      [
        %NostrBasics.Filter{subscription_id: filter.subscription_id, limit: 10},
        %NostrBasics.Filter{subscription_id: filter.subscription_id, limit: 5000}
      ]
  """
  @spec cap_max_limit(list()) :: :ok
  def cap_max_limit(filters) do
    filters
    |> Enum.map(fn %Filter{limit: limit} = filter ->
      new_limit = min(limit || 0, @max_limit)
      %Filter{filter | limit: new_limit}
    end)
  end

  @doc """
  Make sure subscription ID aren't longer than the value in configuration settings

  ## Examples
      iex> filter = Relay.Support.Generators.Filter.new()
      ...> [%NostrBasics.Filter{filter | subscription_id: "1234567890"}]
      ...> |> Relay.Nostr.Connection.RequestValidator.validate_subscription_id_length()
      :ok

      iex> filter = Relay.Support.Generators.Filter.new()
      ...> large_subscription_id = Relay.Support.Generators.Values.string(257)
      ...> [%NostrBasics.Filter{filter | subscription_id: large_subscription_id}]
      ...> |> Relay.Nostr.Connection.RequestValidator.validate_subscription_id_length()
      {:error, "Filter subscription id size is limited to 256 bytes"}
  """
  @spec validate_subscription_id_length(list()) :: :ok | {:error, String.t()}
  def validate_subscription_id_length(filters) do
    all_below_max_size? =
      filters
      |> Enum.map(& &1.subscription_id)
      |> Enum.map(&(String.length(&1) <= @max_subid_length))
      |> Enum.all?()

    if all_below_max_size? do
      :ok
    else
      {:error, ~s(Filter subscription id size is limited to #{@max_subid_length} bytes)}
    end
  end

  @doc """
  Make sure there aren't more subscriptions than the limit in the configuration settings

  ## Examples
      iex> registry_name = Relay.Support.Generators.Registries.generate()
      ...> Relay.Support.Generators.Filter.new()
      ...> |> Relay.Nostr.Filters.add(registry: registry_name)
      ...> Relay.Nostr.Connection.RequestValidator.validate_number_of_current_subscriptions(2, registry: registry_name)
      :ok

      iex> registry_name = Relay.Support.Generators.Registries.generate()
      ...> Relay.Support.Generators.Filter.new()
      ...> |> Relay.Nostr.Filters.add(registry: registry_name)
      ...> Relay.Support.Generators.Filter.new()
      ...> |> Relay.Nostr.Filters.add(registry: registry_name)
      ...> Relay.Nostr.Connection.RequestValidator.validate_number_of_current_subscriptions(2, registry: registry_name)
      {:error, "Maximum of 2 subscriptions reached"}
  """
  @spec validate_number_of_current_subscriptions(integer(), list()) :: :ok | {:error, String.t()}
  def validate_number_of_current_subscriptions(
        max_number_of_subscriptions \\ @max_number_of_subscriptions,
        opts \\ []
      ) do
    registry = Enum.into(opts, %{}) |> Map.get(:registry, @default_filters_registry)

    subscriptions = Filters.subscriptions_by_pid(self(), registry: registry)

    if Enum.count(subscriptions) >= max_number_of_subscriptions do
      {:error, ~s(Maximum of #{max_number_of_subscriptions} subscriptions reached)}
    else
      :ok
    end
  end

  @doc """
  Make sure an event doesn't have more filters than the limit in the configuration settings

  ## Examples
      iex> [Relay.Support.Generators.Filter.new()]
      ...> |> Relay.Nostr.Connection.RequestValidator.validate_number_of_filters(2)
      :ok

      iex> [Relay.Support.Generators.Filter.new(), Relay.Support.Generators.Filter.new(), Relay.Support.Generators.Filter.new()]
      ...> |> Relay.Nostr.Connection.RequestValidator.validate_number_of_filters(2)
      {:error, "Cannot add more than 2 filters at a time"}
  """
  @spec validate_number_of_filters(list(), integer()) :: :ok | {:error, String.t()}
  def validate_number_of_filters(
        filters,
        max_number_of_filters \\ @max_number_of_filters
      ) do
    if Enum.count(filters) <= max_number_of_filters do
      :ok
    else
      {:error, ~s(Cannot add more than #{max_number_of_filters} filters at a time)}
    end
  end
end

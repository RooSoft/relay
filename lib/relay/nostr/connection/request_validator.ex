defmodule Relay.Nostr.Connection.RequestValidator do
  @moduledoc """
  Request valdation to make sure it respects sane maximum defaults
  """

  alias NostrBasics.Filter

  alias Relay.Nostr.{Filters}

  @max_subid_length Application.compile_env(:relay, :max_subid_length, 256)
  @max_number_of_subscriptions Application.compile_env(:relay, :max_subscriptions, 10)
  @max_number_of_filters Application.compile_env(:relay, :max_filters, 10)
  @max_limit Application.compile_env(:relay, :max_limit, 5000)

  def validate_max_limit(filters) do
    filters
    |> Enum.map(fn %Filter{limit: limit} = filter ->
      new_limit = min(limit, @max_limit)
      %Filter{filter | limit: new_limit}
    end)

    :ok
  end

  def validate_subscription_id_length(filters) do
    all_below_max_size? =
      filters
      |> Enum.map(& &1.subscription_id)
      |> Enum.map(&(String.length(&1) <= @max_subid_length / 2))
      |> Enum.all?()

    if all_below_max_size? do
      :ok
    else
      {:error, ~s(Filter subscription id size is limited to #{@max_subid_length} bytes)}
    end
  end

  def validate_number_of_current_subscriptions do
    subscriptions = Filters.subscriptions_by_pid()

    if Enum.count(subscriptions) >= @max_number_of_subscriptions do
      {:error, ~s(Maximum of #{@max_number_of_subscriptions} subscriptions reached)}
    else
      :ok
    end
  end

  def validate_number_of_filters(filters) do
    if Enum.count(filters) <= @max_number_of_filters do
      :ok
    else
      {:error, ~s(Cannot add more than #{@max_number_of_filters} filters at a time)}
    end
  end
end

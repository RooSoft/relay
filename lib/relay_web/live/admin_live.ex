defmodule RelayWeb.AdminLive do
  use RelayWeb, :live_view
  require Logger

  import RelayWeb.Live.Components.Filter

  alias Relay.Nostr.Filters

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    subscribe_filter_events()

    {
      :ok,
      socket
      |> update_filters()
    }
  end

  @impl true
  def handle_info({:added_filter, _pid, _filter}, socket) do
    {
      :noreply,
      socket
      |> update_filters()
    }
  end

  @impl true
  def handle_info({:removed_subscription, _pid, _subscription_id}, socket) do
    {
      :noreply,
      socket
      |> update_filters()
    }
  end

  defp subscribe_filter_events() do
    Filters.Subscriptions.subscribe()
  end

  defp update_filters(socket) do
    filters =
      Filters.list()
      |> group_by_pid
      |> subgroup_by_subscription_id

    socket
    |> assign(:filters, filters)
  end

  defp group_by_pid(filter_list) do
    filter_list
    |> Enum.group_by(fn {_sub, pid, _filter} -> pid end)
  end

  defp subgroup_by_subscription_id(filter_list) do
    keys = Map.keys(filter_list)

    values =
      Enum.map(keys, fn key ->
        Map.get(filter_list, key, [])
        |> group_by_subscription_id()
      end)

    Enum.zip(keys, values)
    |> Enum.into(%{})
  end

  defp group_by_subscription_id(filter_list) do
    filter_list
    |> Enum.group_by(fn {subscription_id, _pid, _filter} -> subscription_id end)
  end
end

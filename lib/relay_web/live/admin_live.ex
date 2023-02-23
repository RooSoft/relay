defmodule RelayWeb.AdminLive do
  use RelayWeb, :live_view
  require Logger

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

    socket
    |> assign(:filters, filters)
  end

  defp group_by_pid(filter_list) do
    filter_list
    |> Enum.group_by(fn {_sub, pid, _filter} -> pid end)
  end
end

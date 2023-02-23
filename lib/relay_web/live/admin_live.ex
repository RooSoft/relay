defmodule RelayWeb.AdminLive do
  use RelayWeb, :live_view
  require Logger

  alias Relay.Nostr.Filters

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    subscribe_filter_events()

    filters =
      Filters.list()
      |> group_by_pid

    {
      :ok,
      socket
      |> assign(:filters, filters)
    }
  end

  @impl true
  def handle_info({:added_filter, pid, filter}, state) do
    IO.inspect(filter, label: "ADDED FILTER #{inspect(pid)}")

    {:noreply, state}
  end

  @impl true
  def handle_info({:removed_subscription, pid, subscription_id}, state) do
    IO.inspect(subscription_id, label: "REMOVED SUBSCRIPTION #{inspect(pid)}")

    {:noreply, state}
  end

  defp subscribe_filter_events() do
    Filters.Subscriptions.subscribe()
  end

  defp group_by_pid(filter_list) do
    filter_list
    |> Enum.group_by(fn {_sub, pid, _filter} -> pid end)
  end
end

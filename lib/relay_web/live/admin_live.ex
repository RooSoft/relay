defmodule RelayWeb.AdminLive do
  use RelayWeb, :live_view
  require Logger

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    subscriptions =
      Relay.Connection.Filters.list()
      |> group_by_pid

    {
      :ok,
      socket
      |> assign(:subscriptions, subscriptions)
    }
  end

  defp group_by_pid(filter_list) do
    filter_list
    |> Enum.group_by(fn {sub, pid, filter} -> pid end)
  end
end

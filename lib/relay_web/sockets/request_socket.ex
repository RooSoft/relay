defmodule RelayWeb.Sockets.RequestSocket do
  @behaviour Phoenix.Socket.Transport

  require Logger

  alias Relay.Connection

  @impl true
  def child_spec(_opts) do
    %{id: __MODULE__, start: {Task, :start_link, [fn -> :ok end]}, restart: :transient}
  end

  @impl true
  def connect(%{connect_info: %{peer_data: peer}} = state) do
    Logger.info("NEW CONNECTION: #{inspect(peer)}")

    {:ok, state}
  end

  @impl true
  def init(%{options: options} = state) do
    ping_timeout = Map.get(options, :ping_timeout, 30_000)

    Process.send_after(self(), :ping, ping_timeout)

    {:ok, state}
  end

  @impl true
  def handle_in({request, _opts}, %{connect_info: %{peer_data: peer}} = state) do
    Connection.handle(request, peer)

    {:ok, state}
    #    {:reply, :ok, {:text, result}, state}
  end

  @impl true
  def handle_info(:ping, %{options: options} = state) do
    ping_timeout = Map.get(options, :ping_timeout, 30_000)

    Process.send_after(self(), :ping, ping_timeout)

    {:push, {:ping, ""}, state}
  end

  @impl true
  def handle_info({:emit, json}, state) do
    {:reply, :ok, {:text, json}, state}
  end

  @impl true
  def handle_info(stuff, state) do
    Logger.debug("HANDLE INFO #{stuff}")

    {:ok, state}
  end

  @impl true
  def handle_control({nil, [opcode: :pong]}, state) do
    {:ok, state}
  end

  @impl true
  def handle_control(stuff, state) do
    Logger.debug("HANDLE CONTROL #{stuff}")

    {:ok, state}
  end

  @impl true
  def terminate(_reason, %{connect_info: %{peer_data: peer}} = _state) do
    Logger.info("CLOSING CONNECTION: #{inspect(peer)}")

    Connection.terminate(peer)

    :ok
  end
end

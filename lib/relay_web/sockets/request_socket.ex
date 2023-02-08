defmodule RelayWeb.Sockets.RequestSocket do
  @behaviour Phoenix.Socket.Transport

  alias Relay.Connection

  @impl true
  def child_spec(_opts) do
    %{id: __MODULE__, start: {Task, :start_link, [fn -> :ok end]}, restart: :transient}
  end

  @impl true
  def connect(%{connect_info: %{peer_data: peer}} = state) do
    IO.inspect(peer, label: "INCOMING CONNECTION")

    {:ok, state}
  end

  @impl true
  def init(%{options: options} = state) do
    ping_timeout = Keyword.get(options, :ping)

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
    ping_timeout = Keyword.get(options, :ping)

    Process.send_after(self(), :ping, ping_timeout)

    {:push, {:ping, ""}, state}
  end

  @impl true
  def handle_info({:emit, subscription_id, event}, state) do
    json = Jason.encode!(["EVENT", subscription_id, event])

    IO.inspect(json, label: "SENDING")

    {:reply, :ok, {:text, json}, state}
  end

  @impl true
  def handle_info(stuff, state) do
    IO.inspect(stuff, label: "HANDLE INFO")

    {:ok, state}
  end

  @impl true
  def handle_control({nil, [opcode: :pong]}, state) do
    IO.puts("GOT A PONG")
    {:ok, state}
  end

  @impl true
  def handle_control(stuff, state) do
    IO.inspect(stuff, label: "HANDLE CONTROL")
    {:ok, state}
  end

  @impl true
  def terminate(_reason, %{connect_info: %{peer_data: peer}} = _state) do
    Connection.terminate(peer)

    :ok
  end
end

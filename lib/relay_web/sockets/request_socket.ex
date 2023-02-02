defmodule RelayWeb.Sockets.RequestSocket do
  @behaviour Phoenix.Socket.Transport

  @impl true
  def child_spec(_opts) do
    IO.inspect("CHILD SPECS")
    %{id: __MODULE__, start: {Task, :start_link, [fn -> :ok end]}, restart: :transient}
  end

  @impl true
  def connect(state) do
    IO.puts("INCOMING CONNECTION")

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
    result =
      request
      |> Jason.decode!()
      |> Relay.Request.handle(peer)
      |> Jason.encode!()

    {:reply, :ok, {:text, result}, state}
  end

  @impl true
  def handle_info(:ping, %{options: options} = state) do
    ping_timeout = Keyword.get(options, :ping)

    Process.send_after(self(), :ping, ping_timeout)

    {:push, {:ping, ""}, state}
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
  def terminate(reason, %{connect_info: %{peer_data: peer}} = state) do
    Relay.Request.terminate(peer)

    :ok
  end
end

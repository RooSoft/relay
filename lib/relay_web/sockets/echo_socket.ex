defmodule RelayWeb.Sockets.EchoSocket do
  @behaviour Phoenix.Socket.Transport

  @impl true
  def child_spec(_opts) do
    %{id: __MODULE__, start: {Task, :start_link, [fn -> :ok end]}, restart: :transient}
  end

  @impl true
  def connect(state) do
    IO.puts("CONNECTED")

    {:ok, state}
  end

  @impl true
  def init(%{options: options} = state) do
    ping_timeout = Keyword.get(options, :ping)

    Process.send_after(self(), :ping, ping_timeout)

    {:ok, state}
  end

  @impl true
  def handle_in({request, _opts}, state) do
    request
    |> Jason.decode!()
    |> Relay.Request.handle()

    {:reply, :ok, {:text, request}, state}
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
  def terminate(reason, state) do
    IO.inspect(reason, label: "TERMINATE")
    IO.inspect(state)

    :ok
  end
end

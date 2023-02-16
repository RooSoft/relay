defmodule Relay.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      RelayWeb.Telemetry,
      # Start the Ecto repository
      Relay.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Relay.PubSub},
      # Start Finch
      {Finch, name: Relay.Finch},
      # Start the Endpoint (http/https)
      RelayWeb.Endpoint,
      # Start a worker by calling: Relay.Worker.start_link(arg)
      # {Relay.Worker, arg}
      {Registry, [keys: :duplicate, name: Registry.Filters]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Relay.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RelayWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

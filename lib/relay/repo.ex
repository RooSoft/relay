defmodule Relay.Repo do
  use Ecto.Repo,
    otp_app: :relay,
    adapter: Ecto.Adapters.Postgres
end

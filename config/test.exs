import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :relay, Relay.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "relay_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :relay, RelayWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "YOE4dghEW4kZdxaMJucZ5gbChxxiGvavwMr2WGPGZqw7E/LFauQc2r2okAaTDkZr",
  server: false

# In test we don't send emails.
config :relay, Relay.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :relay,
  nip_11_document: [
    name: "test relay",
    description: "Built on top of the Open Telecom Platform (OTP)",
    pubkey: "5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2",
    contact: "5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2",
    supported_nips: [1, 4, 9, 11, 15],
    software: "https://github.com/RooSoft/relay.git",
    websockets: [
      timeout: 120_000,
      keepalive: 60_000
    ],
    limitation: [
      max_message_length: 1000,
      max_subscriptions: 2,
      max_filters: 2,
      max_limit: 5000,
      max_subid_length: 64,
      min_prefix: 4,
      max_event_tags: 25,
      max_content_length: 1024,
      min_pow_difficulty: 0,
      auth_required: false,
      payment_required: false
    ]
  ]

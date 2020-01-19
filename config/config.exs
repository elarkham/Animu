import Config

#############
#   ANIMU   #
#############

# General application configuration
config :animu,
  ecto_repos: [Animu.Repo],
  input_root:  "/home/ethan/net/charon/videos/anime/animu",
  output_root: "/home/ethan/net/hydra/animu"

# Configures the endpoint
config :animu, Animu.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8RUI1CjD9XzQaHIUL3A6bBkokIUjTAUzMBWUwjn8n9hCwERFljL+DcIT+cQsrfYx",
  render_errors: [view: Animu.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Animu.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configure Authentication
config :animu, Animu.Auth.Guardian,
  issuer: "Animu",
  ttl: {30, :days},
  verify_issuer: true,
  secret_key: "default_key"

#############
#   Augur   #
#############

config :animu, Augur.Scanner,
  scan_interval: 5 * 60_000 # 5min

config :animu, Augur.Transmission,
  url: "http://cthulhu:9091/transmission/rpc",
  recv_timeout: 20 * 1000, # 20 seconds
  poll_interval: 2 * 1000  # 2 seconds

############
#   Kiln   #
############

# Configure Kiln
config :kiln,
  ledger: Animu.Kiln.Ledger

##############
#   Elixir   #
##############

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

###############
#   Pheonix   #
###############

# Configure Phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

# Configure Json encoder
config :phoenix, :format_encoders,
  json: Jason

############
#   Ecto   #
############

# Configure Ecto
#config :ecto, json_library: Jason

import_config "#{Mix.env}.exs"



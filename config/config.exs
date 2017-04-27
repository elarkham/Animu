#
#This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

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

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure Phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

# Configure Authentication
config :guardian, Guardian,
  issuer: "Animu",
  ttl: {30, :days},
  verify_issuer: true,
  secret_key: "default_key",
  serializer: Animu.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"



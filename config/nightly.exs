import Config

#############
#   ANIMU   #
#############

# Configure HTTP Endpoint
config :animu, Animu.Web.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: {:system, "HOST"}, port: {:system, "PORT"}],
  server: true,
  root: ".",
  version: Mix.Project.config[:version]


# Configure file paths for nightly
config :animu,
  input_root:  "/mnt/charon/videos/anime/animu",
  output_root: "/mnt/hydra/animu"

##############
#   Elixir   #
##############

# Nightly should print debug information
config :logger, level: :debug

import_config "nightly.secret.exs"

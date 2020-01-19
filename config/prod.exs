import Config

#############
#   ANIMU   #
#############

config :animu, Animu.Web.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: {:system, "HOST"}, port: {:system, "PORT"}],
  server: true,
  root: ".",
  version: Mix.Project.config[:version]


# Configure file paths for production
config :animu,
  input_root:  "/mnt/charon/videos/anime/animu",
  output_root: "/mnt/hydra/animu"

##############
#   Elixir   #
##############

# Do not print debug messages in production
config :logger, level: :info

import_config "prod.secret.exs"

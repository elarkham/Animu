import Config

#############
#   ANIMU   #
#############

# Configure file paths for dev
config :animu,
  input_root:  "/home/ethan/net/charon/videos/anime/animu",
  output_root: "/home/ethan/net/hydra/animu"

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :animu, Animu.Web.Endpoint,
  http: [port: 4005],
  debug_errors: true,
  code_reloader: true,
  check_origin: false
#  watchers: [npm: ["run", "watch",
#             cd: Path.expand("../assets", __DIR__)]]

# Watch static and templates for browser reloading.
#config :animu, Animu.Web.Endpoint,
#  live_reload: [
#    patterns: [
#      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
#      ~r{priv/gettext/.*(po)$},
#      ~r{lib/animu/web/views/.*(ex)$},
#      ~r{lib/animu/web/templates/.*(eex)$}
#    ]
#  ]

# Configure Authentication
config :animu, Animu.Auth.Guardian,
  issuer: "Animu-Dev",
  ttl: {3, :days},
  secret_key: "dev_key"

##############
#   Elixir   #
##############

# Do not include metadata nor timestamps in development logs
config :logger, :console,
  format: "[$level] $message\n"

###############
#   Pheonix   #
###############

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

############
#   Ecto   #
############

# Configure your database
config :animu, Animu.Repo,
  username: "postgres",
  password: "postgres",
  database: "animu_dev",
  hostname: "localhost",
  pool_size: 10



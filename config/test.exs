import Config

#############
#   ANIMU   #
#############

config :animu, Animu.Web.Endpoint,
  http: [port: 4001],
  server: false

# Configure your database
config :animu, Animu.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "animu_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

##############
#   Elixir   #
##############

# Print only warnings and errors during test
config :logger, level: :warn



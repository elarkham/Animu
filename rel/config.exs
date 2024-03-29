use Distillery.Releases.Config,
  # This sets the default release built by `mix release`
  default_release: :default,
  # This sets the default environment used by `mix release`
  default_environment: :dev

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :dev
end

environment :prod do
  set include_erts: true
  set include_src: false
  set vm_args: "rel/prod.vm.args.eex"
end

environment :nightly do
  set include_erts: true
  set include_src: false
  set vm_args: "rel/nightly.vm.args.eex"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :animu do
  set version: System.get_env("VERSION") || current_version(:animu)
  set commands: [
    "setup": "rel/commands/setup.sh",

    #"golem.setup":  "rel/commands/golem_setup.sh",

    "repo.migrate": "rel/commands/repo_migrate.sh",
    "repo.seed":    "rel/commands/repo_seed.sh",
    "repo.create":  "rel/commands/repo_create.sh",
    "repo.drop":  "rel/commands/repo_drop.sh",
    "repo.reset":  "rel/commands/repo_reset.sh",
  ]
end


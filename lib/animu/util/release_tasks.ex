defmodule Animu.ReleaseTasks do

	@start_apps [
		:crypto,
		:ssl,
		:postgrex,
		:ecto,
		:ecto_sql,
	]

  #@repos Application.get_env(:animu, :ecto_repos, [])

  @repo Animu.Repo
  @repos [@repo]

  def setup(_argv \\ []) do
    repo_create()
    seed()
    golem_setup()
  end

  def golem_setup(_argv \\ []) do
    Golem.setup!()
  end

  def repo_create(_argv \\ []) do
    repo = @repo
    config  = repo.config
    adapter = repo.__adapter__
    case adapter.storage_up(config) do
      :ok ->
        IO.puts "The database for #{inspect repo} has been created"
      {:error, :already_up} ->
        IO.puts "The database for #{inspect repo} has already been created"
      {:error, term} when is_binary(term) ->
        IO.warn "The database for #{inspect repo} couldn't be created: #{term}"
      {:error, term} ->
        IO.warn "The database for #{inspect repo} couldn't be created: #{inspect term}"
    end
  end

  def repo_drop(_argv \\ []) do
    repo = @repo
    config  = repo.config
    adapter = repo.__adapter__
    case adapter.storage_down(config) do
      :ok ->
        IO.puts "The database for #{inspect repo} has been dropped"
      {:error, :already_down} ->
        IO.puts "The database for #{inspect repo} has already been dropped"
      {:error, term} when is_binary(term) ->
        IO.warn "The database for #{inspect repo} couldn't be dropped: #{term}"
      {:error, term} ->
        IO.warn "The database for #{inspect repo} couldn't be dropped: #{inspect term}"
    end
  end

  def repo_reset(_argv \\ []) do
    repo_drop()
    repo_create()
    seed()
  end

	def migrate(_argv \\ []) do
		start_services()
		run_migrations()
		stop_services()
	end

	def seed(_argv \\ []) do
		start_services()
		run_migrations()
		run_seeds()
		stop_services()
	end

	defp start_services do
		IO.puts("Starting dependencies...")
		# Start apps necessary for executing migrations
		Enum.each(@start_apps, &Application.ensure_all_started/1)

		# Start the Repo(s) for app
		IO.puts("Starting repos...")

		# Switch pool_size to 2 for ecto > 3.0
		Enum.each(@repos, & &1.start_link(pool_size: 2))
	end

	defp stop_services do
		IO.puts("Success!")
		:init.stop()
	end

	defp run_migrations do
		Enum.each(@repos, &run_migrations_for/1)
	end
	defp run_migrations_for(repo) do
    app = Keyword.get(repo.config, :otp_app)
		IO.puts("Running migrations for #{app}")
		migrations_path = priv_path_for(repo, "migrations")
		Ecto.Migrator.run(repo, migrations_path, :up, all: true)
	end

	defp run_seeds do
		Enum.each(@repos, &run_seeds_for/1)
	end

	defp run_seeds_for(repo) do
		# Run the seed script if it exists
		seed_script = priv_path_for(repo, "seeds.exs")

		if File.exists?(seed_script) do
			IO.puts("Running seed script..")
			Code.eval_file(seed_script)
		end
	end

	defp priv_path_for(repo, filename) do
		app = Keyword.get(repo.config, :otp_app)

		repo_underscore =
			repo
			|> Module.split()
			|> List.last()
			|> Macro.underscore()

		priv_dir = "#{:code.priv_dir(app)}"

		Path.join([priv_dir, repo_underscore, filename])
	end

end

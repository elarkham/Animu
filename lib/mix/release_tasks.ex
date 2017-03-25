defmodule Animu.ReleaseTasks do

  @start_apps [
    :postgrex,
    :ecto,
  ]

  @repos [
    Animu.Repo
  ]

  def seed do
    IO.puts "Loading Animu.."
    :ok = Application.load(:animu)

    IO.puts "Loading dependencies..."
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    IO.puts "Starting repos..."
    Enum.each(@repos, &(&1.start_link(pool_size: 1)))

    # Run Migrations
    Enum.each(@repos, &run_migrations_for/1)

    # Run Seed script if it exists
    seed_script = seeds_path(:animu)
    if File.exists?(seed_script) do
      IO.puts "Running seed script.."
      Code.eval_file(seed_script)
    end

    IO.puts "Success!"
    :init.stop()
  end

  defp run_migrations_for(repo) do
    IO.puts "Running migrations for #{repo}"
    Ecto.Migrator.run(repo, migrations_path(:animu), :up, all: true)
  end

  defp priv_dir(app), do: "#{:code.priv_dir(app)}"
  defp migrations_path(app), do: Path.join([priv_dir(app), "repo", "migrations"])
  defp seeds_path(app), do: Path.join([priv_dir(app), "repo", "seeds.exs"])

end

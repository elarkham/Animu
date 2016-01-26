ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Animu.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Animu.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Animu.Repo)


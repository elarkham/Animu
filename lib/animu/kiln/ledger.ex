defmodule Animu.Kiln.Ledger do
  use Kiln.Ledger

  import Ecto.Query, only: [from: 2]
  alias Kiln.Golem

  alias Animu.Kiln.GolemDB
  alias Animu.Repo

  #################
  #   Callbacks   #
  #################

  #def init do
  #end

  def load do
    from(
      g in GolemDB,
      where: g.status_type == "active",
      or_where: g.status_type == "queued",
      select: g
    )
    |> Repo.all
    |> Enum.map(&GolemDB.from_golemdb/1)
  end

  def handle_new(%Golem{} = golem) do
    golem
    |> GolemDB.to_golemdb
    |> Repo.insert!(
      on_conflict: :replace_all,
      conflict_target: :id
    )
  end

  #def handle_progress(%Golem{} = golem, _progress) do
  #end

  def handle_status(%Golem{} = golem, _status) do
    golem
    |> GolemDB.to_golemdb
    |> Repo.insert!(
      on_conflict: :replace_all,
      conflict_target: :id
    )
  end

end

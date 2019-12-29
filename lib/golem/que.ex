defmodule Golem.Que do
  alias Que.Persistence, as: QueDB

  def setup!, do: QueDB.Mnesia.setup!
  def setup!(nodes) do
    QueDB.Mnesia.setup!(nodes)
  end

  defdelegate initialize, to: QueDB

  defdelegate all, to: QueDB
  defdelegate all(worker), to: QueDB

  defdelegate completed, to: QueDB
  defdelegate completed(worker), to: QueDB

  defdelegate incomplete, to: QueDB
  defdelegate incomplete(worker), to: QueDB

  defdelegate failed, to: QueDB
  defdelegate failed(worker), to: QueDB

  defdelegate find(job_id), to: QueDB

  defdelegate destroy(job_id), to: QueDB

  defdelegate insert(job), to: QueDB

  defdelegate update(job), to: QueDB

end

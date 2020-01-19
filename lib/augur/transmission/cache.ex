defmodule Augur.Transmission.Cache do
  @moduledoc """
  Serves as interface to internal ETS table that tracks torrent status
  """
  require Logger

  alias Augur.Transmission
  alias Augur.Transmission.Torrent
  alias Phoenix.PubSub

  alias __MODULE__

  ###############
  #   General   #
  ###############

  @doc """
  Initializes ETS table
  """
  def init do
    :ets.new(Cache, [:set, :public, :named_table])
  end

  @doc """
  Returns all torrents within the cache
  """
  def all do
    Cache
    |> :ets.tab2list
    |> Enum.map(fn {_id, torrent} -> torrent end)
  end

  @doc """
  Returns all torrents within the cache with given status
  """
  def all(status) do
    Cache
    |> :ets.tab2list
    |> Enum.map(fn {_id, torrent} -> torrent end)
    |> Enum.filter(fn %Torrent{status: s} -> s == status end)
  end

  @doc """
  Gets golem with given id
  """
  def lookup(id) do
    if :ets.member(Cache, id) do
      [{_id, torrent}] = :ets.lookup(Cache, id)
      torrent
    else
      nil
    end
  end

  @doc """
  Adds torrent to ets, overwriting anything with same id
  """
  def upsert(%Torrent{id: id} = changes) do
    torrent    = lookup(id) || %Torrent{}
    pre_status = torrent.status

    torrent =
      torrent
      |> Torrent.update(changes)
      |> fix_percent
      |> calc_status

    post_status = torrent.status

    if post_status != pre_status do
      handle_status(torrent)
    end

    :ets.insert(Cache, {id, torrent})
    torrent
  end

  @doc """
  Adds list of torrents to ets, overwriting anything with same id
  """
  def upsert(torrents) when is_list(torrents) do
    Enum.map(torrents, fn torrent ->
      Cache.upsert(torrent)
    end)
  end

  ########################
  #   Status Tracking    #
  ########################

  defp fix_percent(%Torrent{progress: prog} = torrent) do
    case prog do
      nil -> %Torrent{torrent | progress: :nil}
      _   -> %Torrent{torrent | progress: prog * 100.0}
    end
  end

  defp calc_status(%Torrent{progress: prog} = torrent) do
    cond do
      prog == nil   -> %Torrent{torrent | status: :pending}
      prog >= 100.0 -> %Torrent{torrent | status: :complete}
      true          -> %Torrent{torrent | status: :active}
    end
  end

  defp handle_status(%Torrent{status: :complete} = torrent) do
    msg = {Transmission, {:complete, torrent}}
    PubSub.broadcast!(Augur.PubSub, "transmission", msg)
    torrent
  end

  defp handle_status(%Torrent{status: :pending} = torrent) do
    torrent
  end

  defp handle_status(%Torrent{status: :active} = torrent) do
    torrent
  end

  defp handle_status(%Torrent{status: status} = torrent) do
    Logger.warn("Augur.Transmission :: Torrent in unknown state: #{inspect status}")
    torrent
  end

end

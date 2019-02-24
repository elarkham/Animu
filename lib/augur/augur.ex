defmodule Augur do
  @moduledoc """
  Scans RSS feeds and auto-downloads anime episodes at fixed interval
  """
  use GenServer

  alias Augur.Transmission
  alias Augur.Torrent
  alias Augur.Scanner

  require Logger

  defstruct feeds: %{},
            anime: %{},
            torrents: %{}

  ## Client

  @doc """
  Start Link
  """
  def start_link(name \\ nil) do
    GenServer.start_link(__MODULE__, :ok, [name: name])
  end

  @doc """
  Get Augur's internal cache state
  """
  def cache do
  	GenServer.call(Augur, :cache)
  end

  @doc """
  Request Augur rebuild it's cache
  """
  def rebuild_cache do
    GenServer.cast(Augur, :rebuild)
  end

  @doc """
  Request Augur scan feeds
  """
  def scan do
    GenServer.cast(Scanner, {:scan, cache()})
  end

  @doc """
  Track active torrents
  """
  def cache_torrents(torrents) do
    GenServer.cast(Augur, {:cache_torrents, torrents})
  end

  ## Server Callbacks

  @doc """
  Builds new cache, schedule loops
  """
  def init(:ok) do
    send self(), :scan
    send self(), :poll
    cache = rebuild()
    {:ok, cache}
  end

  @doc """
  Return the current cached state
  """
  def handle_call(:cache, _from, cache) do
    {:reply, cache, cache}
  end

  @doc """
  Rebuild internal cache
  """
  def handle_cast(:rebuild, cache) do
    cache = rebuild(cache)
    {:noreply, cache}
  end

  @doc """
  Cached torrent states from transmission
  """
  def handle_cast({:cache_torrents, torrents}, cache) do
    torrents =
      Map.merge(torrents, cache.torrents, fn _id, t1, t2 -> Torrent.merge(t2, t1) end)

    finished =
      torrents
      |> Enum.filter(fn {_id, torrent} -> torrent.percent_done >= 1.0 end)
      |> Enum.map(&proccess_finished_torrent/1)

    torrents =
      Map.drop(torrents, Enum.map(finished, &(&1.id)))

    {:noreply, %{cache | torrents: torrents}}
  end

  @doc """
  Poll Transmission status on an interval
  """
  def handle_info(:poll, cache) do
    ids = Map.keys(cache.torrents)
    Transmission.poll(ids)
    Process.send_after(self(), :poll, (2 * 1_000))
    {:noreply, cache}
  end

  @doc """
  Request scan from Feed Scanner on an interval
  """
  def handle_info(:scan, cache) do
    Scanner.scan(cache)
    Process.send_after(self(), :scan, (15 * 60_000))
    {:noreply, cache}
  end

  ## Helper Functions

  defp proccess_finished_torrent({_id, torrent = %Torrent{ep_id: nil}}) do
    Logger.warn "augur attempted to add a torrent with nil ep_id!"
    torrent
  end
  defp proccess_finished_torrent({_id, torrent}) do
    timestamp = DateTime.utc_now()
    episode_params =
      %{"video_path" => torrent.name,
        "augured_at" => timestamp
      }

    episode = Animu.Media.get_episode!(torrent.ep_id)
    Logger.info "adding new episode: #{inspect episode}"

    case Animu.Media.update_episode(episode, episode_params) do
      {:ok, _} ->
        rebuild_cache()
      {:error, changeset} ->
        Logger.error "failed to process video: #{inspect changeset.errors}"
      error ->
        Logger.error "unexpected error while processing video: #{inspect error}"
    end
    torrent
  end

  # Build new cache
  defp rebuild, do: rebuild(%__MODULE__{})
  defp rebuild(cache) do
    anime =
      Animu.Media.all_tracked_anime()

    %__MODULE__{
      cache |
      feeds: build_feeds(anime),
      anime: build_anime(anime)
    }
  end

  # Build feed entry of the cache
  defp build_feeds(watched) do
    Enum.group_by(watched, &(&1.rss_feed), &anime_format/1)
  end

  # Format internal anime data stored within a feed
  defp anime_format(anime) do
    {anime.regex, anime.directory, anime.id}
  end

  # TODO Use non-media-internal structure
  # Build the anime entry of the cache
  defp build_anime(watched) do
    Map.new(watched, fn %Animu.Media.Anime{id: id, episodes: episodes} ->
      {id, episodes}
    end)
  end
end

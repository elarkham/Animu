defmodule Augur.Reader do
  use GenServer

  import Ecto.Query, only: [from: 2]

  alias HTTPoison.Response
  alias Animu.Media.{Series, Episode}
  alias Animu.Media
  alias Animu.Repo

  alias Augur.Torrent

  def start_link(name \\ nil) do
    GenServer.start_link(__MODULE__, :ok, [name: name])
  end

  @doc """
  Generates new cache and starts the scan_feed/2 loop
  """
  def init(:ok) do
    cache = create_cache()
    start_timer()
    {:ok, cache}
  end

  @doc """
  Process finished torrent by adding it to the database and updating the cache
  """
  def handle_cast({:process, torrent}, cache) do
    episode_params = %{"video_path" => torrent.name}
    episode = Media.get_episode!(torrent.ep_id)
    Media.update_episode(episode, episode_params)
    {:noreply, cache}
  end

  @doc """
  Continually scans all feeds every 15 minutes for matching values
  """
  def handle_info(:scan_feeds, cache) do
    cache = scan_feeds(cache)
    start_timer()
    {:noreply, cache}
  end

  # Create cache of database query to stop this module from spamming it
  defp create_cache do
    episode_query =
      from e in Episode,
      where: is_nil(e.video),
      select: {e.id, e.number}
    series_query =
      from s in Series,
      preload: [episodes: ^episode_query],
      where: s.watch == true,
      select: s

    construct_ep = &(Map.new(&1, fn {k, v} -> {k, {:search, v}} end))

    Repo.all(series_query)
    |> Enum.map(fn s ->
        %{feed: s.rss_feed, regex: s.regex,
          dir: s.directory, episodes: construct_ep.(s.episodes)} end)
    |> Enum.reduce(%{}, &(put_in(&2, [&1.feed],
        Map.get(&2, &1.feed, []) ++ [Map.delete(&1, :feed)])))
  end

  # Runs scan_feed/2 once 15min pass
  defp start_timer do
    Process.send_after(self(), :scan_feeds, (15 * 60000))
  end

  # Scan provided rss feeds for matching patterns
  defp scan_feeds(cache) do
    Enum.reduce(cache, %{}, fn ({feed_url, matchers}, acc) ->
      Map.put(acc, feed_url, scan_feed(feed_url, matchers))
    end)
  end

  # Get RSS feed from given url
  defp get_feed(feed_url) do
    # Configure request headers/options
    headers = ["Accept": "application/rss+xml; charset=utf-8"]
    options = [follow_redirect: true]

    # Get and parse feed
    case HTTPoison.get(feed_url, headers, options) do
      {:ok, %Response{body: body}} ->
        FeederEx.parse!(body)
      {:error, %HTTPoison.Error{reason: :timeout}} ->
        :timer.sleep(10 * 1000)
        get_feed(feed_url)
    end
  end

  # Scan provided rss feed for matching patterns
  defp scan_feed(feed_url, matchers) do
    # Download given RSS feed
    feed = get_feed(feed_url)

    # Normalize feed, allows Shana RSS to work
    feed =
      case feed.title do
        "Shana Project RSS" ->
          %{feed | entries: Enum.map(feed.entries, fn e ->
            %FeederEx.Entry{title: e.summary, link: e.id} end)}
        _ ->
          feed
      end

    # 1. Search feed for pattern
    # 2. Convert matched episodes into torrents
    # 3. Mark matched episodes as "found" to avoid duplication
    Enum.reduce(matchers, [], fn (m, m_acc) ->
      {:ok, regex} = Regex.compile(m.regex)
      # Gather all feed entries that match the regex and extract all
      # relevant data from them.
      matches =
        feed.entries
        |> Enum.filter(&(Regex.match?(regex, &1.title)))
        |> Enum.map(&( %{link: &1.link, title: &1.title,
                         num: extract_num(regex, &1.title)/1}))

      # For each episode being searched for, compare with found entry data
      # and determine if their episode numbers line up.
      episodes =
      Enum.reduce(m.episodes, m.episodes, fn({ep_id, {status, num}}, e_acc) ->
        changes =
        Enum.reduce(matches, %{}, fn (match, match_acc) ->
          cond do
            (num == match.num) and (status === :search) ->
              create_torrent(match, m.dir, ep_id, feed_url)
              Map.put(match_acc, ep_id, {:pending, num})
            true ->
              match_acc
          end
        end)
        Map.merge(e_acc, changes)
      end)

      # Merge the new episode search list
      m_acc ++ [%{m | episodes: episodes}]
    end)
  end

  # Creates torrent and sends it off to the Transmission Client
  defp create_torrent(match, dir, ep_id, feed_url) do
    torrent =
      %Torrent{
        ep_id: ep_id,
        ep_num: match.num,
        name: match.title,
        url: match.link,
        dir: dir,
        feed_url: feed_url,
      }
    GenServer.cast(Augur.TransmissionClient, {:add_torrent, torrent})
  end

  # Pull the "num" capture from regex
  defp extract_num(regex, title) do
    {num, _} =
      Regex.named_captures(regex, title)["num"]
      |> Float.parse

    num
  end
end

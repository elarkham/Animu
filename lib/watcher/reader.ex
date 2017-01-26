defmodule Animu.Reader do
  use GenServer

  import Ecto.Query, only: [from: 2]

  alias HTTPoison.Response
  alias Animu.TransmissionClient
  alias Animu.{Repo, Series, Episode}

  def start_link(name \\ nil) do
    GenServer.start_link(__MODULE__, :ok, [name: name])
  end

  @doc """
  Generates new cache and starts the scan_feed/2 loop
  """
  def init(cache) do
    cache = create_cache
    #start_timer
    {:ok, cache}
  end

  @doc """
  Process finished torrent by adding it to the database and updating the cache
  """
  def handle_cast({:process, torrent}, cache) do
    episode_params =
      %{id: torrent.ep_id,
        number: torrent.ep_num,
        video: torrent.name,
      }
    changeset = Episode.changeset(%Episode{}, episode_params)
    Repo.insert!(changeset)

    {:noreply, cache}
  end

  @doc """
  Continually scans all feeds every 15 minutes for matching values
  """
  def handle_info(:scan_feeds, cache) do
    cache = scan_feeds(cache)
    #start_timer
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

     construct_ep =
      &(Map.new(&1, fn {k, v} -> {k, {:search, v}} end))

     cache =
      Repo.all(series_query)
      |> Enum.map(fn s ->
          %{feed: s.rss_feed, regex: s.regex,
            dir: s.directory, episodes: construct_ep.(s.episodes)} end)
      |> Enum.reduce(%{}, &(put_in(&2, [&1.feed],
          Map.get(&2, &1.feed, []) ++ [Map.delete(&1, :feed)])))
  end

  # Runs scan_feed/2 once 15min pass
  defp start_timer do
    Process.send_after(self, :scan_feeds, (15 * 60000))
  end

  # Scan provided rss feeds for matching patterns
  defp scan_feeds(cache) do
    Enum.reduce(cache, %{}, fn ({feed_url, matchers}, acc) ->
      Map.put(acc, feed_url, scan_feed(feed_url, matchers))
    end)
  end

  # Scan provided rss feed for matching patterns
  defp scan_feed(feed_url, matchers) do
    # Configure request headers/options
    headers = ["Accept": "application/rss+xml; charset=utf-8"]
    options = [follow_redirect: true]

    # Get and parse feed
    {:ok, %Response{body: body}} = HTTPoison.get(feed_url, headers, options)
    {:ok, feed, _} = FeederEx.parse(body)

    # Search feed for pattern and convert matches into torrents
    Enum.reduce(matchers, [], fn (m, m_acc) ->
      {:ok, regex} = Regex.compile(m.regex)
      matches =
        feed.entries
        |> Enum.filter(&(Regex.match?(regex, &1.summary)))
        |> Enum.map(&(extract_params(regex, &1)))

      episodes =
      Enum.reduce(m.episodes, m.episodes, fn({ep_id, {status, num}}, e_acc) ->
        changes =
        Enum.reduce(matches, %{}, fn (match, match_acc) ->
          cond do
            (num == match.num) and (status === :search) ->
              create_torrent(match, m.dir, ep_id, feed_url)
              Map.put(match_acc, ep_id, {:found, num})
            true ->
              match_acc
          end
        end)
        Map.merge(e_acc, changes)
      end)

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
    GenServer.cast(Animu.TransmissionClient, {:add_torrent, torrent})
  end

  defp extract_params(regex, entry) do
    %{link: entry.id,
      title: entry.summary,
      num: extract_num(regex, entry.summary)/1
    }
  end

  defp extract_num(regex, title) do
    Regex.named_captures(regex, title)["num"]
    |> String.to_integer
  end

end

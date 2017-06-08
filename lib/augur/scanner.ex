defmodule Augur.Scanner do

  require Logger
  use GenServer

  alias HTTPoison.Response
  alias Augur.Transmission
  alias Augur.Torrent

  ## Client

  def start_link(name \\ nil) do
    GenServer.start_link(__MODULE__, :ok, [name: name])
  end

  def scan(cache) do
    GenServer.cast(Augur.Scanner, {:scan, cache})
  end

  ## Server Callbacks

  @doc """
  Generates new cache and starts the scan_feed/2 loop
  """
  def init(:ok) do
    {:ok, %{}}
  end

  @doc """
  Scans all feeds for matching values
  """
  def handle_cast({:scan, cache}, state) do
    Enum.each(cache.feeds, fn {feed_url, series_list} ->
      case get_feed(feed_url) do
        {:ok, feed} ->
          find_matches(feed, series_list, cache)
        _ ->
          nil
      end
		end)
    {:noreply, state}
  end

  ## Helpers

  # Get RSS feed from given url
  defp get_feed(feed_url) do
    # Configure request headers/options
    headers = ["Accept": "application/rss+xml; charset=utf-8"]
    options = [follow_redirect: true]

    Logger.info("Scanning feed: #{feed_url}")

    # Get and parse feed
    case HTTPoison.get(feed_url, headers, options) do
      {:ok, %Response{body: body, status_code: 200}} ->
        feed = FeederEx.parse!(body) |> normalize_feed
        {:ok, feed}

      {:ok, %Response{status_code: 521}} ->
        Logger.error "Scanner request failed because origin server is down"
        :error

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error "Scanner request failed due to #{reason} error"
        :error

      _ ->
        Logger.error "Scanner request failed due to unknown reasons"
        :error
    end
  end

	# Normalize rss feed to resemble something like Nyaa's
	defp normalize_feed(feed) do
		case feed.title do
        "Shana Project RSS" ->
          %{feed | entries: Enum.map(feed.entries, fn e ->
            %FeederEx.Entry{title: e.summary, link: e.id}
          end)}
				"Nyaa Pantsu" ->
          regex = ~r/<\!\[CDATA\[(?<url>.*)\]\]\>/
          %{feed | entries: Enum.map(feed.entries, fn e ->
            %FeederEx.Entry{ e |
              link: Regex.named_captures(regex, e.link)["url"]
            }
          end)}
        _ ->
          feed
  	end
	end

  # Find all matching episodes and send them to Transmission
  defp find_matches(feed, series_list, cache) do
    Enum.each(series_list, fn {regex, dir, series_id} ->
      feed
      |> find_regex_matches(regex)
      |> find_episode_matches(series_id, cache)
      |> to_torrents(dir)
      |> Transmission.add_torrents()
    end)
  end

  # Scan provided rss feed for matching patterns
  defp find_regex_matches(feed, regex) do
	  case Regex.compile(regex) do
      {:ok, regex} ->
        feed.entries
        |> Enum.filter(&(Regex.match?(regex, &1.title)))
        |> Enum.map(&(Map.put(&1, :num, extract_num(regex, &1.title))))
      _ ->
        []
    end
	end

  # Check if anything found matches a needed episode
  defp find_episode_matches(matches, series_id, cache) do
    episodes =
      Map.new(cache.series[series_id], fn {ep_id, num} -> {num, ep_id} end)

    matches
     |> Enum.filter(&(Enum.member?(Map.keys(episodes), &1.num)))
     |> Enum.map(&(Map.put(&1, :ep_id, episodes[&1.num])))
  end

  # Convert feed entry into Torrent struct
  defp to_torrents(matches, dir) do
    Enum.map(matches, fn m ->
      %Torrent{
        ep_id: m.ep_id,
        name: m.title,
        url: m.link,
        downloadDir: dir
      }
    end)
  end

  # Pull the "num" capture from regex
  defp extract_num(regex, title) do
    {num, _} =
      Regex.named_captures(regex, title)["num"]
      |> Float.parse

    num
  end
end

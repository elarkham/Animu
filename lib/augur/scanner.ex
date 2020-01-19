defmodule Augur.Scanner do
  @moduledoc """
  GenServer dedicated to doing the actual RSS feed scanning
  """
  require Logger
  use GenServer

  alias HTTPoison.Response

  alias Animu.Media

  alias Augur.Transmission
  alias Augur.Transmission.Torrent

  ##############
  #   Client   #
  ##############

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def scan do
    GenServer.cast(__MODULE__, :scan)
  end

  def tree do
    GenServer.call(__MODULE__, :tree)
  end

  ##############
  #   Server   #
  ##############

  # Generates new cache and starts the scan_feed/2 loop
  def init(:ok) do
    schedule_scan()
    {:ok, %{}}
  end

  # Scans all feeds for matching values
  def handle_cast(:scan, _tree) do
    tree = perform_scan()
    {:noreply, tree}
  end
  def handle_info(:scheduled_scan, _tree) do
    tree = perform_scan()
    schedule_scan()
    {:noreply, tree}
  end

  def handle_call(:tree, _from, tree) do
    {:reply, tree, tree}
  end

  ################
  #   Scanning   #
  ################

  defp perform_scan do
    tree = build_tree()
    Enum.each(tree, fn {feed_url, anime_list} ->
      case summon_feed(feed_url) do
        {:ok, feed} ->
          find_matches(feed, anime_list)

        error ->
          Logger.warn("Augur.Scanner failed to parse feed: #{inspect error}")
      end
    end)
    tree
  end

  defp schedule_scan do
    interval =
      :animu
      |> Application.get_env(Augur.Scanner)
      |> Keyword.get(:scan_interval, 5 * 60_000)

    Process.send_after(self(), :scheduled_scan, interval)
  end

  ####################
  #   Tree Building  #
  ####################

  def build_tree do
    Media.all_tracked_anime()
    |> Enum.map(&format_anime/1)
    |> Enum.group_by(&(&1.rss_feed), &Map.delete(&1, :rss_feed))
  end

  defp format_anime(anime), do: %{
    id: anime.id,
    name: anime.name,

    episodes: anime.episodes,
    directory: anime.directory,

    rss_feed: anime.rss_feed,
    regex: anime.regex,
  }

  ######################
  #   Feed Summoning   #
  ######################

  # Get RSS feed from given url
  defp summon_feed(feed_url) do
    headers = [
      "Accept": "application/rss+xml; charset=utf-8"
    ]
    opt = [
      follow_redirect: true
    ]

    Logger.info("Scanning feed: #{feed_url}")

    # Get and parse feed
    case HTTPoison.get(feed_url, headers, opt) do
      {:ok, %Response{body: body, status_code: 200}} ->
        feed = body |> FeederEx.parse! |> normalize_feed()
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
            %FeederEx.Entry{e |
              link: Regex.named_captures(regex, e.link)["url"]
            }
          end)}

        _ -> feed
    end
  end

  ######################
  #   Feed Filtering   #
  ######################

  # Find all matching episodes and send them to Transmission
  defp find_matches(feed, anime_list) do
    Enum.map(anime_list, fn anime ->
      feed
      |> find_regex_matches(anime.regex)
      |> filter_needed_episodes(anime.episodes)
      |> to_transmission(anime)
    end)
  end

  # Scan provided rss feed for matching patterns
  defp find_regex_matches(feed, regex) do
    case Regex.compile(regex) do
      {:ok, regex} ->
        feed.entries
        |> Enum.filter(&Regex.match?(regex, &1.title))
        |> Map.new(&({extract_num(regex, &1.title), &1}))
      error ->
        Logger.warn("Augur.Scanner :: "
        <> "Failed to compile regex: #{inspect regex}, "
        <> "reason: #{inspect error}")
        []
    end
  end

  # Check if anything found matches a needed episode
  defp filter_needed_episodes(matches, episodes) do
    Map.take(matches, episodes)
  end

  # Pull the "num" capture from regex
  defp extract_num(regex, title) do
    {num, _} =
      Regex.named_captures(regex, title)["num"]
      |> Float.parse

    num
  end

  ############################
  #   Torrent Transmission   #
  ############################

  # Send matching feed entries to transmission
  defp to_transmission(matches, anime) do
    matches
    |> Enum.map(fn {num, m} ->
      %Torrent{
        name: m.title,
        input: m.link,
        download_dir: anime.directory,
        augured_at: DateTime.utc_now(),

        # So we know what to do with torrent when it's done
        label: %{
          ep_id: {anime.id, num},
          anime: anime.name,
        }
      }
      |> IO.inspect
    end)
    |> Transmission.add_torrents
  end

end

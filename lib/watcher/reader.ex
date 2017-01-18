defmodule Animu.Reader do
  use GenServer

  alias HTTPoison.Response
  alias Animu.TransmissionClient

  def start_link(_,_) do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    HTTPoison.start
    #    start_timer
    {:ok, %{}}
  end

  def handle_info(:scan_feed, state) do
    scan_feed
    start_timer
    {:noreply, state}
  end

  # Scan rss feed for matching patterns
  defp scan_feed do
    # Get and parse feed
    url = "https://www.nyaa.se/?page=rss&term=horriblesubs"
    headers = ["Accept": "application/rss+xml; charset=utf-8"]
    options = [follow_redirect: true]
    {:ok, %Response{body: body}} = HTTPoison.get(url, headers, options)
    {:ok, feed, _} = FeederEx.parse(body)

    # Search feed for pattern
    matches = Enum.filter(feed.entries, fn(e) -> check(e, ~r/Demi/) end )
    match = List.first(matches)

    # Download torrent
    %Response{body: body} = HTTPoison.get!(match.link, [], options)
    File.write!("/tmp/" <> match.title <> ".torrent", body)
  end

  # Check if element matches pattern
  def check(element, pattern) do
    if String.match?(element.title, pattern) do
      element.link
    end
  end

  # Activate "scan_feed" after 15min pass
  defp start_timer do
    Process.send_after(self, :scan_feed, ( 15 * 60000 ) )
  end

end

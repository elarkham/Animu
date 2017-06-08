defmodule Augur.Transmission do
  use GenServer
  require Logger

  alias HTTPoison.Response
  alias Augur.Torrent

  @url "http://192.168.5.115:9091/transmission/rpc"

  ## Client

  @doc """
  Start Link
  """
  def start_link(name \\ nil) do
    GenServer.start_link(__MODULE__, :ok, [name: name])
  end

  @doc """
  Adds multiple torrent to transmission
  """
  def add_torrents(torrents) do
    Enum.map(torrents, &add_torrent/1)
  end

  @doc """
  Adds a torrent to transmission
  """
  def add_torrent(%Torrent{} = torrent) do
    GenServer.cast(Augur.Transmission, {:add_torrent, torrent})
  end

  @doc """
  Creates torrents using given paramaters and then adds it
  """
  def add_torrent(ep_id, downloadDir, url) do
    torrent =
      %Torrent{
        ep_id: ep_id,
        downloadDir: downloadDir,
        url: url
      }

    GenServer.cast(Augur.Transmission, {:add_torrent, torrent})
  end
  @doc """
  Polls status of torrents from list of ids
  """
  def poll(ids) do
    GenServer.cast(Augur.Transmission, {:poll, ids})
  end

  ## Server Callbacks

  @doc """
  Gets a session_id from transmission rpc
  """
  def init(:ok) do
    {:ok, _, s_id} = request("session-get", %{}, "0")
    {:ok, s_id}
  end

  @doc """
  Adds torrent to transmission
  """
  def handle_cast({:add_torrent, torrent}, s_id) do
    method = "torrent-add"
    path = Application.get_env(:animu, :input_root)
    arguments =
      %{"filename"     => torrent.url,
        "download-dir" => Path.join(path, torrent.downloadDir),
        "paused"       => false,
      }

    case request(method, arguments, s_id) do
      {:ok, %{"arguments" => %{"torrent-added" => torrent_info}}, s_id} ->
        id = torrent_info["id"]
        torrent = %Torrent{torrent | id: id}
        Augur.cache_torrents(%{id => torrent})
        Logger.info("Added torrent: #{inspect torrent}")
        {:noreply, s_id}
      {:ok, %{"arguments" => %{"torrent-duplicate" => torrent_info}}, s_id} ->
        id = torrent_info["id"]
        torrent = %Torrent{torrent | id: id}
        Augur.cache_torrents(%{id => torrent})
        Logger.info("Added duplicate torrent: #{inspect torrent}")
        {:noreply, s_id}
      reply ->
        Logger.error("Failed to add torrent due to: #{reply}")
        {:noreply, s_id}
    end
  end

  @doc """
  Polls the status of torrents from a list of ids
  """
  def handle_cast({:poll, ids}, s_id) do
    {torrents, s_id} = poll(ids, s_id)
    Augur.cache_torrents(torrents)
    {:noreply, s_id}
  end

  ## Helpers

  # Helper function that keeps session_id up to date and sends requests to
  # Transmission's RPC API.
  defp request(method, arguments, session_id) do
    options = [recv_timeout: 20 * 1000]

    headers = [{"X-Transmission-Session-Id", session_id},
               {"Accept", "application/json; charset=utf-8"}]

    body =
      Poison.encode!(%{method: method, arguments: arguments})

    case HTTPoison.post(@url, body, headers, options) do
      {:ok, %Response{status_code: 200, body: body}} ->
        {:ok, Poison.decode!(body), session_id}

      {:ok, %Response{status_code: 409, headers: headers}} ->
        session_id = Map.new(headers)["X-Transmission-Session-Id"]
        request(method, arguments, session_id)

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error "Transmission request failed due to #{reason} error"
        {:error, session_id}

      _ ->
        Logger.error "Transmission request failed due to unkown reasons"
        {:error, session_id}
    end
  end

  # Polls status of tracked torrents
  defp poll([], s_id), do: {%{}, s_id}
  defp poll(ids, s_id) do
    method = "torrent-get"
    arguments =
      %{"fields" => ["id", "percentDone", "downloadDir", "name"],
        "ids" => ids
      }

    case request(method, arguments, s_id) do
      {:ok, %{"arguments" => %{"torrents" => torrents}, "result" => "success"}, s_id} ->
        torrents =
           Map.new(torrents, fn t -> {t["id"], Torrent.new(t)} end)
        {torrents, s_id}

      _ ->
        {%{}, s_id}
    end
  end
end

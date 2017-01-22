defmodule Animu.TransmissionClient do
  use GenServer

  alias HTTPoison.Response
  alias Animu.{WatcherCache, Reader, Torrent}

  @url "http://192.168.5.115:9091/transmission/rpc"

  def start_link(_,_) do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(state) do
    state = %{session_id: "0", torrents: %{}}
    {:ok, _, state} = request("session-get", %{}, state)
    start_timer
    {:ok, state}
  end

  defp request(method, arguments, state) do
    options = [recv_timeout: 5000]

    headers = [{"X-Transmission-Session-Id", state.session_id},
               {"Accept", "application/json; charset=utf-8"}]

    body =
      %{method: method, arguments: arguments}
      |> Poison.Encoder.encode([])
      |> to_string

    case HTTPoison.post(@url, body, headers, options) do
      {:ok, %Response{status_code: 200, body: body}} ->
        {:ok, Poison.decode!(body), state}

      {:ok, %Response{status_code: 409, headers: headers}} ->
        state = %{state | session_id: get_header(headers,"X-Transmission-Session-Id")}
        request(method, arguments, state)

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        {:error, %{}, state}

      :else ->
        {:error, %{}, state}
    end
  end

  defp get_header(headers, key) do
    headers
    |> Enum.filter(fn({k, _}) -> k == key end)
    |> hd
    |> elem(1)
  end

  def handle_call({:add_torrent, torrent}, _from, state) do
    method = "torrent-add"
    arguments =
      %{"filename"     => torrent.url,
        "download-dir" => torrent.dir,
        "paused"       => false,
      }

    case request(method, arguments, state) do
      {:ok, %{"result" => "success", "torrent_added" => torrent_status}, state} ->
        id = torrent_status["id"]
        torrent = %{torrent | id: id}
        state = %{state | torrents: Map.put(state.torrents, id, torrent)}
        {:reply, :ok, state}
      :else ->
        {:reply, :error, state}
    end
  end

  defp start_timer do
    Process.send_after(self, :check_status, (2 * 1000))
  end

  def handle_info(:check_status, state) do
    state =
      case state.torrents do
        %{}   -> state
        :else -> %{state | torrents: poll(state)}
      end

    start_timer
    {:noreply, state}
  end

  defp poll(state) do
    method = "torrent-get"
    arguments =
      %{"fields" => ["id", "isFinished", "percentDone"],
        "ids" => Map.keys(state.torrents)
      }

    {:ok, response, state} = request(method, arguments, state)
    torrents =
      response.arguments.torrents
      |> Map.new(&({&1["id"], %{progress: &1["percentDone"], finished: &1["isFinished"]}}))
      |> Map.merge(state.torrents, fn(_k, v1, v2) -> Map.merge(Map.from_struct(v2), v1) end)
      |> Enum.map(&(process(&1)))
      |> Enum.reject(fn({_k, v}) -> v.finished end)
      |> Map.new(fn({k, v}) -> {k, struct(Torrent, v)} end)
  end

  defp process({_, torrent}) do
    if torrent.finished do
      GenServer.cast(:animu_watcher_cache, {:process, torrent})
    end
  end
end

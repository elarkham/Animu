defmodule Animu.TransmissionClient do
  use GenServer

  alias HTTPoison.Response
  alias Animu.Torrent

  @url "http://192.168.5.115:9091/transmission/rpc"

  def start_link(name \\ nil) do
    GenServer.start_link(__MODULE__, :ok, [name: name])
  end

  @doc """
  Creates initial state map and gets a session_id from transmission
  """
  def init(:ok) do
    state = %{session_id: "0", torrents: %{}}
    {:ok, _, state} = request("session-get", %{}, state)
    start_timer()
    {:ok, state}
  end

  @doc """
  Adds torrent to transmission and then keeps track of it
  """
  def handle_cast({:add_torrent, torrent}, state) do
    method = "torrent-add"
    path = Application.get_env(:animu, :input_root)
    arguments =
      %{"filename"     => torrent.url,
        "download-dir" => path <> torrent.dir,
        "paused"       => false,
      }

    case request(method, arguments, state) do
      {:ok, %{"arguments" => %{"torrent-added" => torrent_info}}, state} ->
        id = torrent_info["id"]
        torrent = %{torrent | id: id}
        torrents = Map.put(state.torrents, id, torrent)
        {:noreply, %{state | torrents: torrents}}
      {:ok, %{"arguments" => %{"torrent-duplicate" => torrent_info}}, state} ->
        IO.puts "Duplicate Torrent:"
        IO.inspect torrent_info
        {:noreply, state}
      reply ->
        IO.inspect reply
        {:noreply, state}
    end
  end

  @doc """
  Checks if any torrents are finished and records their progress into proc state.
  Loops every 2 seconds.
  """
  def handle_info(:check_status, state) do
    state = %{state | torrents: poll(state)}
    start_timer()
    {:noreply, state}
  end

  # Runs poll/2 once 15min pass
  defp start_timer do
    Process.send_after(self(), :check_status, (2 * 1000))
  end

  # Helper function that keeps session_id up to date and sends requests to
  # Transmission's RPC API.
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

  # Polls status of tracked torrents and removes/processes all the ones that are finished
  defp poll(state) do
    method = "torrent-get"
    arguments =
      %{"fields" => ["id", "percentDone"],
        "ids" => Map.keys(state.torrents)
      }

    {:ok, response, state} = request(method, arguments, state)
    response["arguments"]["torrents"]
      |> Map.new(&({&1["id"], %{progress: &1["percentDone"]}}))
      |> Map.merge(state.torrents, fn(_k, v1, v2) -> Map.merge(Map.from_struct(v2), v1) end)
      |> Enum.map(&(process(&1)))
      |> Enum.reject(fn({_k, v}) -> v.progress >= 1.0 end)
      |> Map.new(fn({k, v}) -> {k, struct(Torrent, v)} end)
  end

  # Checks if a torrent is finished and sends it off to Reader so it can update its cache
  # and add the new file to the database.
  defp process({id, torrent}) do
    if torrent.progress >= 1.0 do
      GenServer.cast(Animu.Reader, {:process, torrent})
    end
    {id, torrent}
  end

end

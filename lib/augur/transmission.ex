defmodule Augur.Transmission do
  @moduledoc """
  Interface for Tranmission's JSON RPC API
  """
  use GenServer
  require Logger

  alias HTTPoison.Response

  alias Augur.Transmission.{
    Torrent,
    Cache,
  }

  ##############
  #   Config   #
  ##############

  def config do
    :animu
    |> Application.get_env(__MODULE__)
    |> Map.new
  end

  ##############
  #   Client   #
  ##############

  @doc """
  Start Link
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Adds multiple torrent to transmission
  """
  def add_torrents(torrents) do
    torrents
    |> Enum.map(&add_torrent/1)
  end

  @doc """
  Adds a torrent to transmission
  """
  def add_torrent(%Torrent{} = torrent) do
    GenServer.cast(__MODULE__, {:add_torrent, torrent})
  end

  #############
  #   Server  #
  #############

  @doc """
  Initializes cache, schedules first poll and gets a
  session_id from transmission rpc
  """
  def init(_) do
    Cache.init
    schedule_poll()
    {:ok, _, sid} = request("session-get", %{}, "0")
    {:ok, %{sid: sid, ids: MapSet.new()}}
  end

  @doc """
  Adds torrent to transmission
  """
  def handle_cast({:add_torrent, %Torrent{} = torrent}, %{sid: sid, ids: ids}) do
    method = "torrent-add"
    path = Application.get_env(:animu, :input_root)
    arguments =
      %{"filename"     => torrent.input,
        "download-dir" => Path.join(path, torrent.download_dir),
        "paused"       => false,
      }

    case request(method, arguments, sid) do
      {:ok, %{"arguments" => %{"torrent-added" => t_meta}}, sid} ->
        torrent = %Torrent{torrent | id: t_meta["id"]}
        Cache.upsert(torrent)
        Logger.info("Added torrent: #{inspect torrent.name}")

        {:noreply, %{sid: sid, ids: MapSet.put(ids, torrent.id)}}

      {:ok, %{"arguments" => %{"torrent-duplicate" => t_meta}}, sid} ->
        torrent = %Torrent{torrent | id: t_meta["id"]}
        Cache.upsert(torrent)
        Logger.info("Added duplicate torrent: #{inspect torrent.name}")

        {:noreply, %{sid: sid, ids: MapSet.put(ids, torrent.id)}}

      reply ->
        Logger.warn("Failed to add torrent due to: #{inspect reply}")
        {:noreply, %{sid: sid, ids: ids}}
    end
  end

  @doc """
  Polls the status of torrents in cache
  """
  def handle_info(:poll, %{sid: sid, ids: ids}) do
    %{sid: sid} = poll(sid, ids)
    schedule_poll()
    {:noreply, %{sid: sid, ids: ids}}
  end

  ###############
  #   Helpers   #
  ###############

  # Helper function that keeps session_id up to date and sends requests to
  # Transmission's RPC API.
  defp request(method, arguments, session_id) do
    url = config().url
    headers = [
      {"X-Transmission-Session-Id", session_id},
      {"Accept", "application/json; charset=utf-8"}
    ]
    options = [
      recv_timeout: config().recv_timeout
    ]

    body =
      Poison.encode!(%{method: method, arguments: arguments})

    case HTTPoison.post(url, body, headers, options) do
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

  defp poll(sid, ids = %MapSet{map: map}) when map_size(map) <= 0 do
    %{sid: sid, ids: ids}
  end
  defp poll(sid, ids) do
    method = "torrent-get"
    arguments = %{
      "fields" => [
        "id",
        "name",

        "downloadDir",
        "hashString",

        "errorString",
        "comment",
        "percentDone",
      ],
      "ids" => MapSet.to_list(ids)
    }

    case request(method, arguments, sid) do
      {:ok, %{
        "arguments" => %{"torrents" => torrents},
        "result" => "success"
      }, sid} ->

        torrents
        |> Enum.map(&Torrent.new/1)
        |> Cache.upsert

        %{sid: sid, ids: ids}
      _ ->
        Logger.warn("Failed to poll transmission state")
        %{sid: sid, ids: ids}
    end
  end

  defp schedule_poll do
    Process.send_after(self(), :poll, config().poll_interval)
  end

end

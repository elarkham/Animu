defmodule Animu.Golem do
  require Logger
  use GenServer

  import Ecto.Query, warn: false

  alias Animu.Golem
  alias Animu.Repo
  alias Animu.Media
  alias Animu.Media.{Series, Episode, Kitsu}
  alias Animu.Video
  alias Animu.Video.{VideoTrack, AudioTrack}
  alias Animu.Schema

  ## Client

  #  @doc """
  #  Start Link
  #  """
  #  def start_link(name \\ nil) do
  #    GenServer.start_link(__MODULE__, :ok, [name: name])
  #  end
  #
  #  ## Server Callbacks
  #
  #  @doc """
  #  Schedule loops
  #  """
  #  def init(:ok) do
  #    send self(), :audit
  #    {:ok, []}
  #  end
  #
  #
  #  @doc """
  #  Audit database every 15 minutes
  #  """
  #  def handle_info(:audit, jobs) do
  #    jobs = audit(jobs)
  #    Task.yield_many(jobs, 60 * 60 * 1000)
  #    Process.send_after(self(), :audit, (15 * 60 * 1000))
  #    {:noreply, jobs}
  #  end
  #
  #  ## Helper Functions
  #
  #  defmacro get_field(map, fields) do
  #    quote do
  #      fragment("? #>> ?", unquote(map), unquote(fields))
  #    end
  #  end
  #
  #  def audit(jobs) do
  #    bad_episodes = audit_web_compat()
  #    stale_series = audit_watching()
  #
  #    Enum.map(stale_series ++ bad_episodes, &assign_job/1)
  #  end
  #
  #  def assign_job({:transcode, ep}) do
  #    Task.async(fn ->
  #			series_dir =
  #				ep.series.directory
  #      input_root =
  #        Path.join(Application.get_env(:animu, :input_root), series_dir)
  #      output_root =
  #        Path.join(Application.get_env(:animu, :output_root), series_dir)
  #
  #      dir = Path.join("videos", video.filename)
  #
  #    end)
  #  end
  #
  #  def assign_job({:unwatch, series}) do
  #    Task.async(fn ->
  #      Media.update_series(series, %{watch: false})
  #    end)
  #  end
  #
  #  def assign_job({:update, old_series, new_series}) do
  #    Task.async(fn ->
  #      Media.update_series(old_series, Schema.to_params(new_series))
  #    end)
  #  end
  #
  #  def audit_web_compat() do
  #    query =
  #      from e in Episode,
  #      preload: [:series].
  #      where: get_field(e.video, "{video_track, pix_fmt}") == "yuv444p10le",
  #      select: e
  #
  #    bad = Repo.all(query)
  #    Enum.map(bad, fn(ep) ->
  #      {:transcode, ep}
  #    end)
  #  end
  #
  #  def audit_kitsu() do
  #    series =
  #      Series
  #      |> Repo.all()
  #      |> Repo.preload(:episodes)
  #
  #    kitsu =
  #      Kitsu.request("anime", Enum.map(series, &(&1.kitsu_id)))
  #
  #    Enum.map(series, fn s ->
  #      k = Kitsu.format_to_series(kitsu[s.kitsu_id], s)
  #      {:update, s, struct(s, k)}
  #    end)
  #  end
  #
  #  def audit_watching() do
  #    ep_query =
  #      from e in Episode,
  #      where: not is_nil(e.video),
  #      select: {e.id, e.number}
  #    query =
  #      from s in Series,
  #      preload: [episodes: ^ep_query],
  #      where: s.watch == true,
  #      select: s
  #
  #    Repo.all(query)
  #      |> Enum.filter(&(Enum.count(&1.episodes) == &1.episode_count))
  #      |> Enum.map(&({:unwatch, &1}))
  #  end
end

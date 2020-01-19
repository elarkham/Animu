defmodule Animu.Util.FFmpeg do
  require Logger

  @exec  "/usr/bin/ffmpeg"
  @probe "/usr/bin/ffprobe"

  def probe(input) do
    args =
      [ "-v", "quiet",
        "-print_format", "json",
        "-show_format",
        "-show_streams",
        input
      ]

    with {json_output, 0} <- System.cmd(@probe, args),
         {:ok, probe_data} <- Poison.Parser.parse(json_output) do
      {:ok, probe_data}
    else
      {:error, _} -> {:error, "failed to parse ffprobe output"}
      _           -> {:error, "ffprobe failed"}
    end
  end

  def probe!(input) do
    {:ok, probe_data} = probe(input)
    probe_data
  end

  def get_duration(input) do
    args = [
      "-v", "quiet",
      "-show_entries", "format=duration",
      "-of", "default=noprint_wrappers=1:nokey=1",
      input
    ]
    {duration, 0} = System.cmd(@probe, args)
    {duration, _} = Float.parse(duration)

    # Convert seconds to microseconds
    duration * 1000.0 * 1000.0
  end

  def mkv_to_mp4(golem, input, output) do
    run_cmd = Application.app_dir(:animu, "priv/run_cmd")
    duration = get_duration(input)

    args = [
        @exec,
        "-i", input,
        "-v", "quiet",
        "-progress", "-",
        "-y",
        "-c:v", "copy",
        "-c:a", "copy",
        output
      ]

    options = [:stderr_to_stdout, :binary, :exit_status, args: args]
    port = Port.open({:spawn_executable, run_cmd}, options)

    stream_output(golem, port, duration)
  end

  defp stream_output(golem, port, duration) do
    receive do
      {^port, {:data, data}} ->
        progress(golem, data, duration)
        stream_output(golem, port, duration)

      {^port, {:exit_status, 0}}      -> :ok
      {^port, {:exit_status, status}} -> {:error, status}
    end
  end

  defp progress(golem, data, duration) do
    status =
      data
      |> String.split("\n", trim: true)
      |> Enum.map(fn str -> String.split(str, "=", trim: true) end)
      |> Enum.map(fn [s1, s2] -> {s1, s2} end)
      |> Map.new

    out_time = String.to_integer(status["out_time_ms"])
    prog = Float.round(out_time / duration, 6)

    status =
      status
      |> Map.put("status", status["progress"])
      |> Map.put("duration_ms", duration)
      |> Map.put("progress", prog)

    Kiln.set_progress(golem, {prog, status})
  end

  def vc_10bit_to_8bit(input, output) do
    args =
      [ "-i", input,
        "-hide_banner",
        "-loglevel", "panic",
        "-nostats",
        "-y",
        "-pix_fmt", "yuv420p",
        output
      ]

    System.cmd @exec, args
  end

  def ac_eac3_to_aac(input, output) do
    args =
      [ "-i", input,
        "-hide_banner",
        "-loglevel", "panic",
        "-nostats",
        "-y",
        "-c:a", "aac",
        "-b:a", "160k",
        output
      ]

    System.cmd @exec, args
  end

  def get_thumbnail(input, time, output) when is_binary(time) do
    args =
      [ "-hide_banner",
        "-loglevel", "panic",
        "-nostats",
        "-ss", time,
        "-i", input,
        "-y",
        "-frames:v", "1",
        output,
        "-noaccurate_seek"
      ]

    System.cmd @exec, args
  end
  def get_thumbnail(input, time, output) do
    time = Integer.to_string(time)
    get_thumbnail(input, time, output)
  end

  def random_thumbnail(input, duration, output) do
      time = :rand.uniform(duration)
      get_thumbnail(input, time, output)
  end
  def random_thumbnail(input, output) do
    with   {:ok, data} <- probe(input),
              duration <- data["format"]["duration"],
         {duration, _} <- Integer.parse(duration) do
      random_thumbnail(input, duration, output)
    else
      _ -> {:error, "failed to generate random thumbnail"}
    end
  end

  def extract_subtitles(input, output) do
    args =
      [ "-i", input,
        "-hide_banner",
        "-loglevel", "panic",
        "-nostats",
        "-y",
        "-c:s", "copy",
        output
      ]

    System.cmd @exec, args
  end

  def extract_fonts(input, output) do
    input = Path.absname(input)
    args =
      [ "-dump_attachment:t",
        "",
        "-i", input,
        "-hide_banner",
        "-loglevel", "panic",
        "-nostats",
        "-y",
      ]

    # This will always "fail" since there is no output given
    System.cmd @exec, args, cd: output
  end
end

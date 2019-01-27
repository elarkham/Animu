defmodule Animu.Media.FFmpeg do

  @exec  "ffmpeg"
  @probe "ffprobe"

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
      {:error, _} -> {:error, "Failed to parse FFprobe output"}
      _           -> {:error, "FFProbe Failed"}
    end
  end

  def probe!(input) do
    {:ok, probe_data} = probe(input)
    probe_data
  end

  def mkv_to_mp4(input, output) do
    args =
      [ "-i", input,
        "-hide_banner",
        "-loglevel", "panic",
        "-nostats",
        "-y",
        "-c:v", "copy",
        "-c:a", "copy",
        output
      ]

    System.cmd @exec, args
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
      _ -> {:error, "Failed to generate random thumbnail"}
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

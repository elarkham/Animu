defmodule Augur.Transmission.Torrent do
  @moduledoc """
  Struct Transmission torrent data is stored within
  """

  alias __MODULE__

  defstruct id: nil,
            name: nil,

            input: nil,
            download_dir: nil,
            augured_at: nil,
            hash: nil,

            status: nil,
            label: nil,

            error: nil,
            comment: nil,
            progress: 0.0

  def new(stat) when is_map(stat) do
    error = nil
    if stat["errorString"] != "" do
      error = stat["errorString"]
    end

    %Torrent{
      id: stat["id"],
      name: stat["name"],

      input: stat["filename"],
      #download_dir: stat["downloadDir"],
      hash: stat["hashString"],

      error: error,
      comment: stat["comment"],
      progress: stat["percentDone"],
    }
  end

  def update(cur = %Torrent{}, changes = %Torrent{}) do
    changes =
      changes
      |> Map.from_struct
      |> Enum.reject(fn {_k, v} -> v == nil end)

    struct(cur, changes)
  end

end

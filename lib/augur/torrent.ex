defmodule Augur.Torrent do
  @moduledoc """
  Struct Transmission torrent data is stored within
  """

  defstruct id: nil,
            ep_id: nil,
            url: nil,
            downloadDir: nil,
            name: nil,
            percentDone: 0.0

  def new(
    %{"id" => id,
      "downloadDir" => dir,
      "percentDone" => pd,
      "name" => name
     }) do

    %__MODULE__{
      id: id,
      downloadDir: dir,
      percentDone: pd,
      name: name,
    }
  end

  def merge(t1 = %__MODULE__{}, t2 = %__MODULE__{}) do
    changes =
      t2
      |> Map.from_struct
      |> Enum.reject(fn {_k, v} -> v == nil end)

    struct(t1, changes)
  end
end

defmodule Augur.Torrent do

  defstruct id: nil,
            ep_id: nil,
            url: nil,
            downloadDir: nil,
            name: nil,
            percentDone: 0.0

  def new(
    %{ "id" => id,
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
      Map.from_struct(t2)
      |> Enum.reject(fn {_k, v} -> v == nil end)

    struct(t1, changes)
  end
end

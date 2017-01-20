defmodule Torrent do
  defstruct name: nil,
            dir: nil,
            index: nil,
            url: nil,
            progress: nil,
            finished: false
end

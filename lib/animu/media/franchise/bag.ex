defmodule Animu.Media.Franchise.Bag do
  alias Animu.Media.Franchise
  alias Animu.Repo

  alias __MODULE__, as: Bag

  defstruct [
    :data,

    :output_dir,
    :dir,

    :poster_url,
    :poster_image,
    :poster_dir,

    :cover_url,
    :cover_image,
    :cover_dir,
  ]

  def new(%Franchise{} = franchise, options \\ []) do
    output_root = Application.get_env(:animu, :output_root)

    output_dir =
      case franchise.directory do
        nil -> nil
        dir -> Path.join(output_root, dir)
      end

    %Bag{
      data: franchise,

      output_dir: output_dir,
      dir: franchise.directory,

      poster_url: franchise.poster_url,
      poster_image: nil,
      poster_dir: "images/poster",

      cover_url: franchise.cover_url,
      cover_image: nil,
      cover_dir: "images/cover",
     }
  end

end

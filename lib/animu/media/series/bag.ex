defmodule Animu.Media.Series.Bag do
  alias Animu.Media.Series
  alias Animu.Media.Upload.Image
  alias Animu.Repo

  alias __MODULE__, as: Bag

  defstruct [
    :kitsu_id,
    :kitsu_data,
    :kitsu_eps,

    :output_dir,
    :input_dir,

    :dir,
    :regex,

    :poster_image,
    :poster_dir,

    :cover_image,
    :cover_dir,

    :episodes,
    :ep_count,

    :populate,
    :spawn_episodes,
    :audit,
  ]

  def new(%Series{} = series, options \\ []) do
    series  =
      series
      |> Repo.preload(:episodes)
      |> Repo.preload(:franchise)

    options = Map.new(options)

    populate = Map.get(options, :populate, false)
    spawn_ep = Map.get(options, :spawn_episodes, false)
    audit    = Map.get(options, :audit, false)

    output_root = Application.get_env(:animu, :output_root)
    input_root  = Application.get_env(:animu, :input_root)

    {output_dir, input_dir} =
      case series.directory do
        nil ->
          {nil, nil}
        dir ->
          { Path.join(output_root, dir),
            Path.join(input_root,  dir) }
      end

    %Bag{
      kitsu_id: series.kitsu_id,
      kitsu_data: nil,
      kitsu_eps: [],

      output_dir: output_dir,
      input_dir:  input_dir,

      dir: series.directory,
      regex: series.regex,

      poster_image: series.poster_image,
      poster_dir: "images/poster",

      cover_image: series.cover_image,
      cover_dir: "images/cover",

      episodes: series.episodes,
      ep_count: series.episode_count,

      populate: populate,
      spawn_episodes: spawn_ep,
      audit: audit,
     }
  end

  def apply_kitsu_data(%Bag{} = bag, kitsu_data) do
    episode_count =
      case kitsu_data.episode_count do
        nil -> bag.ep_count
        _   -> kitsu_data.episode_count
      end

    types = %{poster_image: Image, cover_image: Image}
    images = %{
      poster_image: kitsu_data.poster_urls["original"],
      cover_image:  kitsu_data.cover_urls["original"]
    }
    images =
      {%{poster_image: nil, cover_image: nil}, types}
      |> Ecto.Changeset.cast(images, Map.keys(types))
      |> Ecto.Changeset.apply_changes

    bag
    |> Map.put(:episode_count, episode_count)
    |> Map.put(:kitsu_data, kitsu_data)
    |> Map.put(:poster_image, images.poster_image)
    |> Map.put(:cover_image, images.cover_image)
  end
end

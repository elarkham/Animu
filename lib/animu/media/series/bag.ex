defmodule Animu.Media.Series.Bag do
  import Ecto.{Query, Changeset}, warn: false
  import Animu.Schema

  alias Animu.Media.Series
  alias Animu.Ecto.Image
  alias Animu.Repo

  alias __MODULE__, as: Bag

  defstruct [
    :output_root,
    :input_root,

    :dir,
    :output_dir,
    :input_dir,

    :options,
    :params,
    :series,

    :golems,
    :pending,

    :todo,
    :errors,
    :summons,
    :actions,

    :episodes,
    :data,
  ]

  def new(%Series{} = series, %{} = params, options \\ []) do
    ch =
      series
      |> Repo.preload(:episodes)
      |> Repo.preload(:franchise)
      |> cast(params, all_fields(Series))
      |> validate_required([:directory])

    if ch.valid? do
      {:ok, construct(ch, options)}
    else
      {:error, ch.errors}
    end
  end

  defp construct(%Changeset{} = ch, options) do
    params = ch.changes
    series = ch.data
    data = apply_changes(ch)

    output_root = Application.get_env(:animu, :output_root)
    input_root  = Application.get_env(:animu, :input_root)

    dir = data.directory
    output_dir = Path.join(output_root, dir)
    input_dir  = Path.join(input_root, dir)

    episodes =
      case data.episodes do
        nil -> []
        eps -> [eps]
      end

    %Bag {
      output_root: output_root,
      input_root: input_root,

      dir: dir,
      output_dir: output_dir,
      input_dir: input_dir,

      options: options,
      params: params,
      series: series,

      golems:  [],
      pending: [],

      todo: [],
      errors: [],
      summons: [],
      actions: [].

      episodes: episodes,
      data: data,
    }
  end

end

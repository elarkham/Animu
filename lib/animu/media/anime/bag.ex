defmodule Animu.Media.Anime.Bag do
  @moduledoc """
  Intermediate format for Anime mutations
  """
  import Ecto.{Query, Changeset}, warn: false
  import Animu.Util.Schema

  alias Ecto.Changeset
  alias Animu.Media.Anime
  alias Animu.Ecto.Image
  alias Animu.Repo

  alias __MODULE__
  alias Bag.{Invoke, Compile}

  defstruct [
    :input_root,
    :output_root,

    :dir,
    :input_dir,
    :output_dir,

    :options,
    :params,
    :anime,

    :golems,
    :pending,

    :todo,
    :regex,
    :summons,

    :valid?,
    :errors,

    :episodes,
    :data,
  ]

  defdelegate invoke(bag),  to: Invoke
  defdelegate compile(bag), to: Compile

  def new(%Anime{} = anime, %{} = attrs, options \\ []) do
    ch =
      anime
      |> Repo.preload(:episodes)
      |> Repo.preload(:franchise)
      |> Repo.preload(:genres)
      |> Repo.preload(:season)
      |> cast(attrs, all_fields(Anime))
      |> validate_required([:directory])

    if ch.valid? do
      bag =
        ch
        |> construct(options)
        |> compile_regex

      {:ok, bag}
    else
      {:error, ch.errors}
    end
  end

  defp construct(%Changeset{} = ch, options) do
    params = ch.changes
    anime = ch.data
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
      anime: anime,

      golems:  [],
      pending: [],

      todo: [],
      regex: data.regex,
      summons: [],

      valid?: true,
      errors: [],

      episodes: episodes,
      data: data,
    }
  end

  defp compile_regex(%Bag{regex: nil} = bag), do: bag
  defp compile_regex(%Bag{regex: reg} = bag) do
    case Regex.compile(reg) do
      {:error, {error, num}} when is_integer(num) ->
        Bag.error(bag, "Provided Regex Failed: #{error}")
      {:ok, regex} ->
        Map.put(bag, :regex, regex)
    end
  end

  def error(%Bag{} = bag, error) do
    bag
    |> Map.put(:errors, bag.errors ++ [error])
    |> Map.put(:valid?, false)
  end

  def add_todos(%Changeset{} = chgset, %Bag{} = bag) do
    prepare_changes(chgset, fn ch ->
      Enum.reduce(bag.todo, ch, fn todo, acc ->
        todo.(acc)
      end)
    end)
  end

end

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
  alias Bag.Invoke

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

  defdelegate invoke(bag),      to: Invoke

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

  ## Bag Compilation
  def compile(%Bag{valid?: false} = bag), do: {:error, bag.errors}
  def compile(%Bag{} = bag) do
    episodes = compile_episodes(bag)
    summoned = compile_summons(bag)
    anime   = compile_anime(bag, summoned, episodes)
    {:ok, anime}
  end

  # Compile -> Episodes
  defp compile_episodes(%Bag{} = bag) do
    {force, fallback} = summoned_eps(bag)
    episodes = fallback ++ bag.episodes ++ force

    merge_episode_lists(episodes)
  end

  defp summoned_eps(%Bag{} = bag) do
    groups =
      bag.summons
      |> Enum.group_by(&(&1.force))
      |> Map.put_new(true,  [])
      |> Map.put_new(false, [])

    force    = Enum.map(groups[true], &(&1.episodes))
    fallback = Enum.map(groups[false], &(&1.episodes))
    {force, fallback}
  end

  defp merge_episode_lists(ep_lists) do
    ep_lists
    |> Enum.concat
    |> Enum.group_by(&(&1.number))
    |> Enum.map(fn {_k, eps} ->
         Enum.reduce(eps, %{}, fn ep, acc ->
           merge_episodes(acc, ep)
         end)
       end)
  end

  defp merge_episodes(ep1, ep2) do
    Map.merge(ep1, ep2, fn _k, v1, v2 ->
      case v1 do
        "Episode" <> _ -> v2
        nil -> v2
        _ -> v1
      end
    end)
  end

  # Compile -> Summons
  defp compile_summons(%Bag{} = bag) do
    groups = Enum.group_by(bag.summons, &(&1.force))
    force    = merge_summons(groups[true])
    fallback = merge_summons(groups[false])
    {force, fallback}
  end

  defp merge_summons([]),  do: %{}
  defp merge_summons(nil), do: %{}
  defp merge_summons(summons) do
    summons = Enum.map(summons, &(&1.data))
    Enum.reduce(summons, fn sum, acc ->
      Map.merge(sum, acc)
    end)
  end

  # Compile -> Anime
  defp compile_anime(%Bag{} = bag, summoned, episodes) do
    {force, fallback} = summoned
    anime =
      bag.params
      |> Map.merge(force)
      |> merge_if_nil(fallback)

    Map.put(anime, :episodes, episodes)
  end

  defp merge_if_nil(anime1, anime2) do
    Map.merge(anime1, anime2, fn _k, v1, v2 ->
      case v1 do
        nil -> v2
          _ -> v1
      end
    end)
  end

end

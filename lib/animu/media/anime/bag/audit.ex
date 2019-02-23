defmodule Animu.Media.Anime.Bag.Audit do
  @moduledoc """
  Trys to determine value of field using existing local data
  """
  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset

  alias Animu.Media.Anime.Bag
  alias Animu.Media.Anime.{Season, Episode}
  alias Animu.Util

  ## Calc
  def calc(%{calc: fields, force: f}, %Bag{} = bag) do
    Enum.reduce_while(fields, {:ok, bag}, fn field, acc ->
      {:ok, bag} = acc
      case calc(field, bag, force: f) do
           {:ok, bag} -> {:cont, {:ok, bag}}
        {:error, msg} -> {:halt, {:error, %{"calc" => msg}}}
      end
    end)
  end
  def calc(_, bag), do: {:ok, bag}

  ## Calc -> Episode Count
  def calc(:episode_count, bag, force: false) do
    {:ok, %Bag{bag | todo: [&ep_count/1 | bag.todo]}}
  end
  def calc(:episode_count, bag, force: _) do
    {:ok, %Bag{bag | todo: [&force_ep_count/1 | bag.todo]}}
  end

  defp ep_count(ch) do
    case Changeset.get_change(ch, :episode_count) do
      nil -> force_ep_count(ch)
        _ -> ch
    end
  end
  defp force_ep_count(ch) do
    count =
      ch
      |> Changeset.get_field(:episodes, [])
      |> length

    Changeset.put_change(ch, :episode_count, count)
  end

  ## Calc -> Season
  def calc(:season, bag, force: false) do
    {:ok, %Bag{bag | todo: [&calc_season/1 | bag.todo]}}
  end
  def calc(:season, bag, force: _) do
    {:ok, %Bag{bag | todo: [&force_calc_season/1 | bag.todo]}}
  end
  defp calc_season(ch) do
    case Changeset.get_change(ch, :season) do
      nil -> force_calc_season(ch)
        _ -> ch
    end
  end
  defp force_calc_season(ch) do
    start_date = Changeset.get_field(ch, :start_date)
    end_date   = Changeset.get_field(ch, :end_date)
    case Season.in_range(start_date, end_date) do
      nil -> ch
      seasons ->
        Changeset.put_change(ch, :season, seasons)
    end
  end

  ## Calc -> End Date
  def calc(:end_date, bag, force: false) do
    {:ok, %Bag{bag | todo: [&calc_end_date/1 | bag.todo]}}
  end
  def calc(:end_date, bag, force: _) do
    {:ok, %Bag{bag | todo: [&force_calc_end_date/1 | bag.todo]}}
  end
  defp calc_end_date(ch) do
    augur_date = Changeset.get_field(ch, :augur_date)
    cur_date = Util.date_now()
    case Date.diff(cur_date, augur_date) do
      diff when diff > 7 ->
        ch.put_change(:end_date, augur_date)

      _ -> ch
    end
  end
  defp force_calc_end_date(ch) do
    augur_date = Changeset.get_field(ch, :augur_date)
    ch.put_change(:end_date, augur_date)
  end
  def calc(_, bag, _), do: {:ok, bag}

  ## Scan
  def scan(%{scan: fields, force: f}, %Bag{} = bag) do
    Enum.reduce_while(fields, {:ok, bag}, fn field, acc ->
      {:ok, bag} = acc
      case scan(field, bag, force: f) do
           {:ok, bag} -> {:cont, {:ok, bag}}
        {:error, msg} -> {:halt, {:error, %{"scan" => msg}}}
      end
    end)
  end
  def scan(_, bag), do: {:ok, bag}

  ## Scan -> Episodes
  def scan(:episodes, %Bag{} = bag, force: force) do
    with   {:ok, bag} <- validate_regex(bag),
         {:ok, files} <- File.ls(bag.input_dir),
           {:ok, bag} <- scan_anime_dir(files, bag) do

      {:ok, bag}
    else
      # if directory doesn't exist, there is nothing to scan
      {:error, :enoent} -> {:ok, bag}
      {:error, reason}  -> {:error, reason}
      _ -> {:error, "Unexpected Error During Episode Scan"}
    end
  end

  defp scan_anime_dir(files, bag) do
    try do
      {episodes, golems} =
        files
        |> Enum.filter(&(Regex.match?(bag.regex, &1)))
        |> Enum.map(fn filename ->
            {num, _} =
              Regex.named_captures(bag.regex, filename)["num"]
              |> Float.parse()

            Episode.new_lazy(num, filename)
        end)
        |> Enum.unzip

      pending = Enum.map(episodes, &(&1.number))

      bag =
        bag
        |> Map.put(:episodes, bag.episodes ++ [episodes])
        |> Map.put(:pending,  pending ++ bag.pending)
        |> Map.put(:golems,   golems  ++ bag.golems)

      {:ok, bag}
    rescue
      _ in MatchError -> {:error, "Failed to parse episode filename"}
    end
  end

  # Regex Handling
  defp validate_regex(%Bag{} = bag) do
    case bag do
      %{regex: nil} ->
        {:error, "Regex Is Required For Audit"}
      %{regex: _} ->
        {:ok, bag}
    end
  end

end

defmodule Animu.Media.Series.Bag.Audit do
  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset

  alias Animu.Media.Series.Bag
  alias Animu.Media.{Season, Episode}
  alias Animu.Util

  ## Calc
  def calc(%{fields: fields, force: f}, %Bag{} = bag) do
    Enum.reduce_while(fields, bag, fn field, acc ->
      {:ok, bag} = acc
      case calc(field, bag, force: f) do
           {:ok, bag} -> {:cont, {:ok, bag}}
        {:error, msg} -> {:halt, {:error, %{"scan" => msg}}}
      end
    end)
  end

  ## Calc -> Episode Count
  def calc(:episode_count, bag, force: false) do
    %Bag{bag | actions: [ep_count/1 | bag.functions]}
  end
  def calc(:episode_count, bag, force: _) do
    %Bag{bag | actions: [force_ep_count/1 | bag.functions]}
  end

  defp ep_count(ch) do
    case Changeset.get_change(:episode_count) do
      nil -> force_ep_count(ch)
        _ -> ch
    end
  end
  defp force_ep_count(ch) do
    count =
      ch
      |> Changeset.get_field(:episodes, [])
      |> list_size

    Changeset.put_change(ch, :episode_count, count)
  end

  ## Calc -> Season
  def calc(:season, bag, force: false) do
    %Bag{bag | actions: [calc_seasons/1 | bag.functions]}
  end
  def calc(:season, bag, force: _) do
    %Bag{bag | actions: [force_calc_seasons/1 | bag.functions]}
  end
  defp calc_season(ch) do
    case Changeset.get_change(:season) do
      nil -> force_calc_seasons(ch)
        _ -> ch
    end
  end
  defp force_calc_season(ch) do
    start_date = Changeset.get_field(ch, :start_date)
    end_date   = Changeset.get_field(ch, :end_date)
    case Season.in_range(start_date, end_date) do
      nil -> ch
      seasons ->
        Changeset.put_change(:season, seasons)
    end
  end

  ## Calc -> End Date
  def calc(:end_date, bag, force: false) do
    %Bag{bag | actions: [calc_end_date/1 | bag.functions]}
  end
  def calc(:end_date, bag, force: _) do
    %Bag{bag | actions: [force_calc_end_date/1 | bag.functions]}
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
    augur_date = Changeset.get_field(:augur_date)
    ch.put_change(:end_date, augur_date)
  end

  def calc(_, bag, _), do: bag

  ## Scan
  def scan(%{fields: fields, force: force}, %Bag{} = bag) do
    Enum.reduce_while(fields, bag, fn field, acc ->
      {:ok, bag} = acc
      case scan(field, bag) do
           {:ok, bag} -> {:cont, {:ok, bag}}
        {:error, msg} -> {:halt, {:error, %{"scan" => msg}}}
      end
    end)
  end

  def scan(:episodes, %Bag{} = bag) do
    with   {:ok, bag} <- validate_regex(bag)
         {:ok, files} <- File.ls(bag.input_dir),
           {:ok, eps} <- scan_series_dir(files, bag) do

      {:ok, %Bag{bag | episodes: bag.episodes ++ [eps]}}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unexpected Error During Episode Scan"}
    end
  end
  def scan(_, bag), do: {:ok, bag}

  defp scan_series_dir(files, bag) do
    try do
      episodes =
        files
        |> Enum.filter(&(Regex.match?(bag.regex, &1)))
        |> Enum.map(fn filename ->
            {num, _} =
              Regex.named_captures(bag.regex, filename)["num"]
              |> Float.parse()
            spawn_episode(num, filename)
          end)

      {:ok, episodes}
    rescue
      _ in MatchError -> {:error, "Failed to parse episode filename"}
    end
  end

  defp validate_regex(bag) do
    with {:ok, bag} <- validate_regex_not_nil(bag),
         {:ok, bag} <- validate_regex_compiles(bag),
         do: {:ok, bag}
  end

  defp validate_regex_not_nil(bag) do
    case bag do
      %{regex: nil} ->
        {:error, "Regex Is Required For Audit"}
      %{regex: _} ->
        {:ok, bag}
    end
  end

  def validate_regex_compiles(bag = %Bag{regex: nil}), do: {:ok, bag}
  def validate_regex_compiles(bag) do
    case Regex.compile(bag.regex) do
      {:error, {error, num}} when is_integer(num) ->
        {:error, "Provided Regex Failed: #{error}"}
      {:ok, regex} ->
        {:ok, Map.put(bag, :regex, regex)}
    end
  end
end

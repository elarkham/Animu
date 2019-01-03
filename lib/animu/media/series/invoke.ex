defmodule Animu.Media.Series.Invoke do
  import Ecto.Changeset

  import Animu.Media.Series.Validate
  import Animu.Media.Series.Collect
  import Animu.Media.Series.Conjure
  import Animu.Media.Series.Transmute

  alias Ecto.Changeset
  alias Animu.Media.Series

  def summon_images(%Series{} = series) do
    with       bag  <- transmute(series, :bag),
         {:ok, bag} <- conjure_images(bag),
            series  <- transmute(bag, :series) do
      {:ok, series}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unexpected Error Summoning Images"}
    end
	end
  def summon_images(changeset = %Changeset{valid?: false}), do: changeset
  def summon_images(changeset = %Changeset{changes: %{poster_image: nil, cover_image: nil}}), do: changeset
  def summon_images(changeset = %Changeset{}) do
    with       series  <- transmute(changeset, :series),
         {:ok, series} <- summon_images(series),
            changeset  <- transmute(series, changeset) do
      changeset
    else
      {:error, reason} ->
        add_error(changeset, :summon_images, reason)
    end
  end


  def populate(%Series{} = series) do
    with       bag  <- transmute(series, :bag),
         {:ok, bag} <- validate_kitsu_id(bag),
         {:ok, bag} <- validate_series_dir(bag),
         {:ok, bag} <- collect_kitsu_data(bag),
         {:ok, bag} <- conjure_images(bag),
         {:ok, bag} <- spawn_episodes(:kitsu, bag),
            series  <- transmute(bag, :series) do

      {:ok, series}
    else
      {:error, reason} -> {:error, reason}
      error -> {:error, "Unexpected Error: #{error}"}
    end
	end
  def populate(changeset = %Changeset{valid?: false}), do: changeset
  def populate(changeset = %Changeset{changes: %{populate: true}}) do
    with       series  <- transmute(changeset, :series),
         {:ok, series} <- populate(series),
        new_changeset  <- transmute(series, changeset) do
      merge(new_changeset, changeset)
    else
      {:error, reason} ->
        add_error(changeset, :populate, reason)
    end
  end
  def populate(%Changeset{} = changeset), do: changeset

  def audit(%Series{} = series) do
    with       bag  <- transmute(series, :bag),
         {:ok, bag} <- validate_series_dir(bag),
         {:ok, bag} <- validate_regex(bag),
         {:ok, bag} <- spawn_episodes(:audit, bag),
            series  <- transmute(bag, :series) do
      {:ok, series}
    else
      {:error, reason} -> {:error, reason}
      error -> {:error, "Unexpected Error: #{error}"}
    end
	end
  def audit(changeset = %Changeset{valid?: false}), do: changeset
  def audit(changeset = %Changeset{changes: %{audit: true}}) do
    with       series  <- transmute(changeset, :series),
         {:ok, series} <- audit(series),
            changeset  <- transmute(series, changeset) do
      changeset
    else
      {:error, reason} ->
        add_error(changeset, :audit, reason)
    end
  end
  def audit(%Changeset{} = changeset), do: changeset

  def spawn_episodes(%Series{} = series) do
    with       bag  <- transmute(series, :bag),
         {:ok, bag} <- spawn_episodes(:spawn, bag),
            series  <- transmute(bag, :series) do
      {:ok, series}
    else
      {:error, reason} -> {:error, reason}
      error -> {:error, "Unexpected Error: #{error}"}
    end
	end
  def spawn_episodes(changeset = %Changeset{valid?: false}), do: changeset
  def spawn_episodes(changeset = %Changeset{changes: %{spawn_episodes: true}}) do
    with       series  <- transmute(changeset, :series),
         {:ok, series} <- spawn_episodes(series),
            changeset  <- transmute(series, changeset) do
      changeset
    else
      {:error, reason} ->
        add_error(changeset, :spawn_episodes, reason)
    end
  end
  def spawn_episodes(%Changeset{} = changeset), do: changeset
end

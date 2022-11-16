defmodule Animu.Kiln.Video do
  @moduledoc """
  Handles video transcoding jobs
  """
  use Kiln.Golem.Chem, priority: 0, max_attempts: 1
  require Logger

  alias Kiln.Golem

  alias Animu.Media
  alias Animu.Media.Anime.Video

  def perform(golem, path: path, num: num, anime: anime) do
    progress_cb = fn {prog, status} ->
      Kiln.set_progress(golem, {prog, status})
    end

    with {:ok, video} <- Video.new(path, anime.directory, progress_cb),
                   ep <- find_ep(anime.episodes, num),
            {:ok, ep} <- Media.update_episode(ep, video) do

      {:ok, ep}
    else
      {:error, msg} when is_binary(msg) -> {:error, msg}
      error ->
        {:error, "Unexpected error: #{inspect error}"}
    end
  end

  def perform(golem, path: {dir, name}, ep_id: {anime_id, ep_num}, augured_at: ts) do
    progress_cb = fn {prog, status} ->
      Kiln.set_progress(golem, {prog, status})
    end

    with {:ok, video} <- Video.new(name, dir, progress_cb),
                   ep <- Media.get_episode!(anime_id, ep_num),
            {:ok, ep} <- Media.update_episode(ep, video, %{augured_at: ts}) do

      {:ok, ep}
    else
      {:error, msg} when is_binary(msg) -> {:error, msg}
      error ->
        {:error, "Unexpected error: #{inspect error}"}
    end
  end

  defp find_ep(episodes, number) do
    Enum.find(episodes, fn ep -> ep.number == number end)
  end

end

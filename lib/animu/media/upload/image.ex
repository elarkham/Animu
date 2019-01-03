defmodule Animu.Media.Upload.Image do
  @behaviour Ecto.Type

  alias HTTPoison.Response
  alias __MODULE__, as: Image
  require Logger

  ## Ecto Type Functions

  def type, do: :map

  def cast(image = %Plug.Upload{}) do
    read_image_data(image.path)
  end
  def cast(image) when is_binary(image) do
    uri = URI.parse(image)
    case uri do
      %URI{scheme: "http"} ->
        download_image_data(image)
      %URI{scheme: "https"} ->
        download_image_data(image)
      %URI{scheme: "data"} ->
        decode_image_data(image)
      _ ->
        read_image_data(image)
    end
  end
  def cast(image) when is_map(image) do
    {:ok, image}
  end
  def cast(_), do: :error

  def load(image) when is_map(image) do
    {:ok, image}
  end

  def dump(image) when is_map(image) do
    {:ok, image}
  end
  def dump(_), do: :error

  ## Helper Functions

  def read_image_data(path) do
    case File.read(path) do
      {:ok, binary} ->
        {:ok, binary}
      _ ->
        Logger.error "Unexpected error when reading #{path}"
        :error
    end
  end

  def decode_image_data(uri) do
    [_, base64] = String.split(uri, ",")
    case Base.decode64(base64) do
      {:ok, binary} ->
        {:ok, binary}
      _ ->
        Logger.error "Failed to decode image"
        :error
    end
  end

  def download_image_data(url) do
    case HTTPoison.get(url) do
   	  {:ok, %Response{body: binary}} ->
        {:ok, binary}
      _ ->
        Logger.error "Failed To Download Image From: '#{url}'"
        :error
    end
  end

end

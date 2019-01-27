defmodule Animu.Web.FranchiseController do
  use Animu.Web, :controller

  alias Animu.Media
  alias Animu.Media.Franchise

  action_fallback Animu.Web.FallbackController

  def index(conn, params) do
    franchises = Media.list_franchises(params)
    render(conn, "index.json", franchises: franchises)
  end

  def create(conn, %{"franchise" => franchise_params}) do
    with {:ok, %Franchise{} = franchise} <- Media.create_franchise(franchise_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", franchise_path(conn, :show, franchise))
      |> render("show.json", franchise: franchise)
    end
  end

  def show(conn, %{"id" => id}) do
    franchise = parse(id) |> Media.get_franchise!()
    render(conn, "show.json", franchise: franchise)
  end

  def update(conn, %{"id" => id, "franchise" => franchise_params}) do
    franchise = parse(id) |> Media.get_franchise!()
    with {:ok, %Franchise{} = franchise} <- Media.update_franchise(franchise, franchise_params) do
      render(conn, "show.json", franchise: franchise)
    end
  end

  def delete(conn, %{"id" => id}) do
    franchise = parse(id) |> Media.get_franchise!()
    with {:ok, %Franchise{}} <- Media.delete_franchise(franchise) do
      send_resp(conn, :no_content, "")
    end
  end

  defp parse(slug) do
    case Integer.parse(slug) do
      {id, _} -> id
      :error -> slug
    end
  end
end

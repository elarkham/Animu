defmodule Animu.Web.FranchiseController do
  use Animu.Web, :controller

  alias Animu.Media
  alias Animu.Media.Franchise

  action_fallback Animu.Web.FallbackController

  ## Helpers
  defp parse(slug) do
    case Integer.parse(slug) do
      {id, _} -> id
      :error -> slug
    end
  end

  #### GET

  ## Index
  def index(conn, params) do
    frans = Media.list_franchises(params)
    render(conn, "index.json", franchises: frans)
  end

  ## Show
  def show(conn, %{"id" => id}) do
    fran = parse(id) |> Media.get_franchise!()
    render(conn, "show.json", franchise: fran)
  end

  #### POST/PATCH

  ## Create
  def create(conn, params = %{"franchise" => attrs}) do
    opt  = params["options"] || %{}
    with {:ok, %Franchise{} = franchise} <- Media.create_franchise(attrs, opt) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", franchise_path(conn, :show, franchise))
      |> render("show.json", franchise: franchise)
    end
  end

  ## Update
  def update(conn, params = %{"id" => id, "franchise" => attrs}) do
    opt  = params["options"] || %{}
    fran = parse(id) |> Media.get_franchise!()
    with {:ok, %Franchise{} = franchise} <- Media.update_franchise(fran, attrs, opt) do
      render(conn, "show.json", franchise: franchise)
    end
  end

  #### DELETE

  ## Delete
  def delete(conn, %{"id" => id}) do
    fran = parse(id) |> Media.get_franchise!()
    with {:ok, %Franchise{}} <- Media.delete_franchise(fran) do
      send_resp(conn, :no_content, "")
    end
  end

end

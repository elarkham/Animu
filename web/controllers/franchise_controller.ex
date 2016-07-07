defmodule Animu.FranchiseController do
  use Animu.Web, :controller

  alias Animu.Franchise

  def index(conn, _params) do
    franchises = Repo.all(Franchise)
    render(conn, "index.json", franchises: franchises)
  end

  def create(conn, %{"franchise" => franchise_params}) do
    changeset = Franchise.changeset(%Franchise{}, franchise_params)

    case Repo.insert(changeset) do
      {:ok, franchise} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", franchise_path(conn, :show, franchise))
        |> render("show.json", franchise: franchise)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Animu.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    franchise = Repo.get!(Franchise, id)
    render(conn, "show.json", franchise: franchise)
  end

  def update(conn, %{"id" => id, "franchise" => franchise_params}) do
    franchise = Repo.get!(Franchise, id)
    changeset = Franchise.changeset(franchise, franchise_params)

    case Repo.update(changeset) do
      {:ok, franchise} ->
        render(conn, "show.json", franchise: franchise)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Animu.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    franchise = Repo.get!(Franchise, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(franchise)

    send_resp(conn, :no_content, "")
  end
end

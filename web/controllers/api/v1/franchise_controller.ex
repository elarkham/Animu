defmodule Animu.FranchiseController do
  use Animu.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Animu.SessionController
  # plug :scrub_params, "franchise" when action in [:create, :update]

  alias Animu.{Repo, Franchise}

  # List all Franchises
  def index(conn, _params) do
    franchises = Repo.all(Franchise)
    render(conn, "index.json", franchises: franchises)
  end

  # Create new Franchise with given params
  def create(conn, %{"franchise" => franchise_params}) do
    changeset = Franchise.changeset(%Franchise{}, franchise_params)

    case Repo.insert(changeset) do
      {:ok, franchise} ->
        conn
        |> put_status(:created)
        |> render("show.json", franchise: franchise )
      {:error, changeset } ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", changeset: changeset)
    end
  end

  # Show Franchise with given id
  def show(conn, %{"id" => id}) do
    franchise = Repo.get(Franchise, id)
    render( conn, "show.json", franchise: franchise )
  end

  # Update Franchise with given id with the given params
  def update(conn, %{"id" => id, "franchise" => franchise_params}) do
    franchise = Repo.get!(Franchise, id)
    changeset = Franchise.changeset(franchise, franchise_params)

    case Repo.update(changeset) do
      {:ok, franchise} ->
        conn
        |> put_status(:created)
        |> render("show.json", franchise: franchise )
      {:error, changeset } ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", changeset: changeset)
    end
  end

  # Delete Franchise with given id
  def delete(conn, %{"id" => id}) do
    franchise = Repo.get!(Franchise, id)

    case Repo.delete(franchise) do
      {:ok, franchise} ->
        conn
        |> put_status(:created)
        |> render("show.json", franchise: franchise )
      {:error, changeset } ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", changeset: changeset)
    end
  end

end

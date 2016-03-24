defmodule Animu.FranchiseView do
  use Animu.Web, :view
  alias Animu.Franchise

  # List of Franchises
  def render("index.json", %{franchises: franchises}) do
    %{franchises: franchises}
  end

  # Single Franchise
  def render("show.json", %{franchise: franchise}) do
    %{franchise: franchise}
  end

  # Franchise Load Error
  def render("error.json", %{changeset: changeset}) do
    # extract the changset errors or return empty map
    errors = Enum.map(changeset.errors, fn {field, detail} ->
      %{} |> Map.put(field, detail)
    end)

    %{errors: errors}
  end

end

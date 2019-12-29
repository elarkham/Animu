defmodule Animu.Media.Anime.Season do
  @moduledoc """
  Organizes Anime by the seasons they aired
  """
  use Animu.Ecto.Schema

  alias Animu.Repo
  alias Animu.Media.Anime

  alias __MODULE__

  schema "season" do
    field :year, :integer # Required
    field :cour, :string  # Required, CI

    field :name,  :string # CS ex: Winter 2019
    field :slug,  :string # CI ex: winter-2019
    field :sort,  :string # CI ex: 2019-0

    many_to_many :anime, Anime,
      join_through: "anime_season",
      defaults: []
  end

  @required  [:year, :cour]
  @generated [:name, :slug, :sort]

  @cours ["winter", "spring", "summer", "fall"]

  # Changeset
  def new(attrs) do
    changeset(%Season{}, attrs)
  end
  def changeset(%Season{} = season, attrs) do
    season
    |> cast(attrs, all_fields(Season, except: @generated))
    |> validate_required(@required)
    |> validate_inclusion(:cour, @cours)
    |> update_change(:cour, &String.downcase/1)
    |> unique_constraint(:cour, name: :seasons_cour_year_index)
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
    |> generate_fields
  end
  defp generate_fields(ch) do
    cour = get_field(ch, :cour)
    year = get_field(ch, :year)

    name  = "#{String.capitalize(cour)} #{year}"
    slug  = "#{cour}-#{year}"
    sort  = "#{year}-#{cour_index(cour)}"

    ch
    |> put_change(:name, name)
    |> put_change(:slug, slug)
    |> put_change(:sort, sort)
  end

  # Param Lists
  def parse_list([]), do: []
  def parse_list([_ | _] = list) do
    list
    |> Enum.reject(& &1 == "")
    |> Enum.map(&String.downcase/2)
    |> Enum.map(&parse_slug/1)
    |> insert_or_get_all
  end

  defp parse_slug(slug) do
    [cour, year] = String.split(slug, parts: 2)
    new(%{cour: cour, year: year})
  end

  defp insert_or_get_all(seasons) do
    slugs   = Enum.map(seasons, &(&1.slug))
    resolve = :nothing
    Repo.insert_all(Season, seasons, on_conflict: resolve)
    Repo.all(from s in Season, where: s.slug in ^slugs)
  end

  # Season from date creation
  def in_range(nil, _), do: nil
  def in_range(_, nil), do: nil
  def in_range(start_date, end_date) do
    # credo:disable-for-lines:5
    Date.range(start_date, end_date)
    |> MapSet.new(&Season.at/1)
    |> MapSet.to_list
    |> insert_or_get_all
  end

  def at(%Date{year: year} = date) do
    params = %{year: year, cour: cour_at(date)}

    %Season{}
    |> changeset(params)
    |> apply_changes
    |> to_map
    |> Map.drop([:anime])
  end

  def cour_at(%Date{} = date) do
    index = Date.quarter_of_year(date)
    Enum.at(@cours, index + 1)
  end

  def cour_index(cour) do
    Enum.find_index(@cours, fn c -> c == cour end)
  end

end

defmodule Animu.Media.Series.Season do
  use Ecto.Schema

  import Ecto.Changeset
  import Animu.Util.Schema

  alias Animu.Media.Series
  alias Animu.Util.Image
  alias Animu.Repo

  alias __MODULE__

  @derive {Poison.Encoder, except: [:__meta__]}
  schema "season" do
    field :year,  :integer # Required
    field :cour,  :string  # Required, CI

    field :title,       :string # CS ex: Winter 2019
    field :slug,        :string # CI ex: winter-2019
    field :poster,      Image

    many_to_many :series, Series,
      join_through: "series_season",
      defaults: []

    timestamps()
  end

  @required  [:year, :cour]
  @generated [:title, :slug]

  @cours ["winter", "spring", "summer", "fall"]

  # Changeset
  def new(attrs) do
    changeset(%Season{}, attrs)
  end
  def changeset(%Season{} = season, attrs) do
    season
    |> cast(attrs, all_fields(Season, except: @generated)
    |> validate_required(@required)
    |> validate_subset(:cour, @cours)
    |> update_change(:cour, &String.downcase/1)
    |> unique_constraint(:cour, name: :seasons_cour_year_index)
    |> generate_fields
  end
  defp generate_fields(ch) do
    cour = ch.get_field(:cour)
    year = ch.get_field(:year)

    title = "#{String.capitalize(cour)} #{year}"
    slug  = "#{cour}-#{year}"

    ch
    |> put_change(:title, title)
    |> put_change(:slug,  slug)
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
    slugs = Enum.map(seasons, &apply_changes/1)
    resolve = :replace_all_except_primary_key
    Repo.insert_all(seasons, on_conflict: resolve)
    Repo.all(from s in Season, where: s.slug in ^slugs)
  end

  # Season from date creation
  def in_range(nil, _), do: nil
  def in_range(_, nil), do: nil
  def in_range(start_date, end_date) do
    Date.range(start_date, end_date)
    |> MapSet.new(&Season.at/1)
    |> Enum.map(&Repo.insert_or_update!/2)
  end

  def at(%Date{year: year} = date) do
    params = %{year: year, cour: cour_at(date)}

    %Season{}
    |> changeset(params)
  end

  def cour_at(%Date{} = date) do
    index = Date.quarter_of_year(date)
    Enum.at(@cours, index + 1)
  end

end

defmodule Animu.Media.Anime.Options do
  @moduledoc """
  Parses Anime options
  """
  use Animu.Ecto.Schema

  alias Animu.Media.Anime
  alias __MODULE__

  defmodule Numbers do
    @behaviour Ecto.Type
    def type, do: {:array, :float}

    defguard is_integers(from, to)
      when is_integer(from) and is_integer(to)

    ## Total, ex: 25
    def cast(total) when is_integer(total) do
      cast(%{from: 1, to: total})
    end
    ## From -> To, ex: {from: 1, to: 5}
    def cast(%{"from" => from, "to" => to}) do
      cast(%{from: from, to: to})
    end
    def cast(%{from: from, to: to}) when is_integers(from, to) do
      from..to
      |> Enum.to_list
      |> cast
    end
    ## Integer Array, ex: [1,2,3]
    def cast(array) when is_list(array) do
      Ecto.Type.cast({:array, :float}, array)
    end
    def cast(_), do: :error
    def load(_), do: :error
    def dump(_), do: :error
  end

  embedded_schema do
    embeds_many :summon, Summon do
      field :source, :string
      field :except, {:array, :string}
      field :only,   {:array, :string}
      field :force,  :boolean, default: false
    end
    embeds_one :audit, Audit do
      field :scan,  {:array, :string}
      field :calc,  {:array, :string}
      field :force, :boolean, default: false
    end
    embeds_one :conjure, Conjure do
      embeds_one :episodes, Episodes do
        field :numbers, Numbers
        field :type,    :string, default: "spawn"
      end
      embeds_many :image, Image do
        field :field, :string
        field :sizes, :map
      end
    end
  end

  def parse(attrs) do
    %Options{}
    |> changeset(attrs)
    |> trim
  end

  defp trim(%Changeset{valid?: false} = ch) do
    errors = Animu.Util.format_errors(ch)
    {:error, errors}
  end
  defp trim(ch) do
    opt =
      ch
      |> apply_changes
      |> to_map
      |> Map.to_list

    {:ok, opt}
  end

  defp changeset(%Options{} = opt, attrs) do
    opt
    |> cast(attrs, [])
    |> cast_embed(:summon,  with: &summon_changeset/2)
    |> cast_embed(:audit,   with: &audit_changeset/2)
    |> cast_embed(:conjure, with: &conjure_changeset/2)
  end

  defp summon_changeset(%_{}, attrs) do
    fields  = all_fields(Anime, as: :string, assoc: true)
    sources = ["kitsu"]

    %Options.Summon{}
    |> cast(attrs, all_fields(Options.Summon))
    |> validate_inclusion(:source, sources)
    |> validate_subset(:only,   fields)
    |> validate_subset(:except, fields)
    |> update_to_atoms(:only)
    |> update_to_atoms(:except)
  end

  defp audit_changeset(%_{}, attrs) do
    fields = all_fields(Anime, as: :string, assoc: true)

    %Options.Audit{}
    |> cast(attrs, all_fields(Options.Audit))
    |> validate_subset(:calc, fields)
    |> validate_subset(:scan, fields)
    |> update_to_atoms(:calc)
    |> update_to_atoms(:scan)
  end

  defp conjure_changeset(%_{}, attrs) do
    %Options.Conjure{}
    |> cast(attrs, [])
    |> cast_embed(:episodes, with: &conj_episodes_changeset/2)
    |> cast_embed(:image,    with: &conj_image_changeset/2)
  end

  defp conj_episodes_changeset(%_{}, attrs) do
    types = ["spawn", "conjure_video", "conjure_thumb"]

    %Options.Conjure.Episodes{}
    |> cast(attrs, all_fields(Options.Conjure.Episodes))
    |> validate_inclusion(:type, types)
  end

  defp conj_image_changeset(%_{}, attrs) do
    fields = ["poster_image", "cover_image"]

    %Options.Conjure.Image{}
    |> cast(attrs, all_fields(Options.Conjure.Image))
    |> validate_inclusion(:field, fields)
    |> update_to_atom(:field)
  end

  defp update_to_atoms(ch, field) do
    case ch.valid? do
      true -> update_change(ch, field, &update_to_atoms/1)
      _ -> ch
    end
  end
  defp update_to_atoms(list) do
    Enum.map(list, &to_atom/1)
  end

  defp update_to_atom(ch, field) do
    case ch.valid? do
      true -> update_change(ch, field, &to_atom/1)
      _ -> ch
    end
  end

  defp to_atom(str) when is_binary(str) do
    String.to_existing_atom(str)
  end
  defp to_atom(value), do: value
end

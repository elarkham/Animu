defmodule Animu.Media.Series.Populate do
  import Ecto.Changeset

  import Animu.Media.Series.Validate
  import Animu.Media.Series.KitsuFetcher
  import Animu.Media.Series.Generate
  import Animu.Media.Series.Assembler

  alias Ecto.Changeset

  alias Animu.Media.Series
  alias Animu.Schema

  def populate_series(changeset = %Changeset{valid?: false}), do: changeset
  def populate_series(changeset = %Changeset{changes: %{populate: true}}) do
    kitsu_id   = get_field(changeset, :kitsu_id, nil)
    dir        = get_field(changeset, :directory, nil)
    regex      = get_field(changeset, :regex, nil)

    gen_k = get_field(changeset, :generate_ep_from_kitsu, false)    |> convert_bool
    gen_e = get_field(changeset, :generate_ep_from_existing, false) |> convert_bool

    case populate(kitsu_id, dir, regex, [gen_kitsu_ep: gen_k, gen_exist_ep: gen_e]) do
      {:ok, series_params} ->
				params = Map.merge(series_params, changeset.params)
        cast(changeset, params, Schema.all_fields(Series))
        |> put_assoc(:episodes, assemble_episodes(series_params["episodes"], dir))

      {:error, reason} ->
        add_error(changeset, :populate, reason)
    end
  end
  def populate_series(changeset), do: changeset

  def populate(kitsu_id, dir, regex, options \\ []) do
    with       series     <- build_map(kitsu_id, dir, regex, options),
         {:ok, series}    <- validate_input(series),
         {:ok, series}    <- compile_regex(series),
         {:ok, series}    <- get_kitsu_data(series),
         {:ok, series}    <- generate_files(series),
         {:ok, series}    <- generate_episodes(series),
               series     <- assemble(series) do
      {:ok, series}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unexpected Error"}
    end
	end

  def convert_bool(value) do
    case value do
      true -> true
      _ -> false
    end
  end

  def build_map(kitsu_id, dir, regex, options) do
    options = Map.new(options)
    output_root = Application.get_env(:animu, :output_root)
    input_root  = Application.get_env(:animu, :input_root)

    %{ kitsu_id: kitsu_id,
       kitsu_data: nil,

       output_dir: Path.join(output_root, dir),
       input_dir: Path.join(input_root, dir),

       dir: dir,
       regex: regex,

       poster_image: nil,
       poster_dir: "images/poster",

       cover_image: nil,
       cover_dir: "images/cover",

       episodes: nil,
       gen_kitsu_ep: Map.get(options, :gen_kitsu_ep, false),
       gen_exist_ep: Map.get(options, :gen_exist_ep, false),
     }
  end

  def compile_regex(series = %{gen_exist_ep: true}) do
    case Regex.compile(series.regex) do
      {:ok, regex} -> {:ok, %{series | regex: regex}}
			{:error, {reason, _}} ->
				{:error, "Series Regex Error: #{reason}"}
    end
  end
  def compile_regex(series), do: {:ok, series}

end

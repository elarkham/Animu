alias Animu.{Repo, Media, Account, Web}
alias Animu.Media.{Anime, Franchise}

alias Anime.{Episode, Video, Season, Genre}

#alias Video.Bag

kitsu_id  = "12497"
directory = "anime/Gabriel DropOut"
regex = "HorribleSubs. Gabriel DropOut - (?<num>.*) .1080p..mkv"


audit   = %{calc: ["season"], scan: ["episodes"]}
summon  = [%{source: "kitsu"}]
conjure = %{episode: %{numbers: [1, 2, 3], type: "conjure_video"}}

gen_opt = fn audit, conjure, summon ->
  %{audit: audit, conjure: conjure, summon: summon}
end

opt = gen_opt.(audit, conjure, summon)
params = %{directory: directory, regex: regex, kitsu_id: kitsu_id}
anime = %Anime{}

module Pages.Home.Rest exposing (..)

import Pages.Home.Types exposing (Msg(..), SeriesData, EpisodeData)
import Models.Series as Series
import Models.Episode as Episode
import Rest

import Http
import HttpBuilder exposing (..)
import Json.Decode as Decode exposing (list, Decoder)
--import Json.Decode.Pipeline as Pipe exposing (required)
import Json.Encode as Encode
import Time

-- Config
series_url : String
series_url =
  Rest.url ++ "/series"

episode_url : String
episode_url =
  Rest.url ++ "/episodes"

-- Json Encoding/Decoding
decodeSeries : Decoder SeriesData
decodeSeries =
  Decode.at ["data"] (list Series.decode)

decodeEpisode : Decoder EpisodeData
decodeEpisode =
  Decode.at ["data"] (list Episode.decode)

-- Commands
getLastWatched : String -> Cmd Msg
getLastWatched token =
  HttpBuilder.get series_url
    |> withQueryParams [("limit", "6")]
    |> withExpect(Http.expectJson decodeSeries)
    |> Rest.send token GetLastWatched

getWeeklyReleases : String -> Cmd Msg
getWeeklyReleases token =
  HttpBuilder.get episode_url
    |> withQueryParams [("limit", "12")]
    |> withExpect(Http.expectJson decodeEpisode)
    |> Rest.send token GetWeeklyReleases

getRecentAdditions : String -> Cmd Msg
getRecentAdditions token =
  HttpBuilder.get series_url
    |> withQueryParams [("limit", "6"), ("orderBy", "started_airing_date")]
    |> withExpect(Http.expectJson decodeSeries)
    |> Rest.send token GetRecentAdditions


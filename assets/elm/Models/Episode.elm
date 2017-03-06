module Models.Episode exposing (..)

import Json.Decode as Decode exposing (int, string, float, bool, list, Decoder)
import Json.Decode.Pipeline as Pipe exposing (required, optional, hardcoded)

type alias Model =
  { title : String
  , synopsis : String
  , thumbnail : Thumbnail
  , kitsu_id : String

  , number : Float
  , season_number : Int
--  , airdate : String

  , video : String
  , subtitles : String
  }

type alias Thumbnail =
  { original : String
  , small : String
  }

init_model : Model
init_model =
  { title = "Episode -1"
  , synopsis = ""
  , thumbnail = {original = "_", small = "_"}
  , kitsu_id = "XXX"

  , number = 0.0
  , season_number = -1
--  , airdate = "_"

  , video = "_"
  , subtitles = "_"
  }

decode : Decoder Model
decode =
  let
    m = init_model
  in
  Pipe.decode Model
    |> required "title" string
    |> optional "synopsis" string m.synopsis
    |> optional "thumbnail" thumbDecoder m.thumbnail
    |> optional "kitsu_id" string m.kitsu_id
    |> required "number" float
    |> optional "season_number" int m.season_number
    |> optional "video" string m.video
    |> optional "subtitles" string m.subtitles

thumbDecoder : Decoder Thumbnail
thumbDecoder =
  let
    m = init_model.thumbnail
  in
  Pipe.decode Thumbnail
    |> optional "original" string m.original
    |> optional "small" string m.small

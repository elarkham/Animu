module Models.User exposing (..)

import Json.Decode as Decode exposing (int, string, Decoder)
import Json.Decode.Pipeline as Pipe exposing (required)

type alias Model =
  { id : Int
  , first_name : String
  , last_name : String
  , email : String
  , username : String
  }

init_model : Model
init_model =
  { id = -1
  , first_name = "error"
  , last_name = "error"
  , email = "error"
  , username = "error"
  }

decode : Decoder Model
decode =
  Pipe.decode Model
    |> required "id" int
    |> required "first_name" string
    |> required "last_name" string
    |> required "email" string
    |> required "username" string



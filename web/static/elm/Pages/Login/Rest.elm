module Pages.Login.Rest exposing (..)

import Pages.Login.Types exposing (Msg(..), Session)
import Models.User as User
import Rest

import Http
import HttpBuilder exposing (..)
import Json.Decode as Decode exposing (string, field, Decoder)
import Json.Decode.Pipeline as Pipe exposing (required)
import Json.Encode as Encode
import Time

-- Config
url : String
url =
  Rest.url ++ "/session"

-- Json Encoding/Decoding
decode : Decoder Session
decode =
  Pipe.decode Session
    |> required "jwt" string
    |> required "user" User.decode

encode : (String, String) -> Encode.Value
encode (username, password) =
  Encode.object
  [ ("session", Encode.object
      [ ("username", Encode.string username)
      , ("password", Encode.string password)
      ]
    )
  ]

errorDecoder : Decoder String
errorDecoder =
  (field "error" string)

-- Commands
authenticate : (String, String) -> Cmd Msg
authenticate cred =
  HttpBuilder.post url
    |> withJsonBody(encode cred)
    |> withExpect(Http.expectJson decode)
    |> withTimeout(10 * Time.second)
    |> Rest.sendRaw SendLogin



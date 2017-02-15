module Pages.Login.Commands exposing (..)

import Http
import Json.Decode exposing (int, string, float, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Json.Encode as Encode

-- Config
url : String
url =
  "http://localhost:4000/api/v1/session"

request : (String, String) -> Http.Request
request login_info =
  { method = "POST"
  , headers = [("Origin", origin)]
  , url = url
  , body = login_info |> encode_login
  , expect = expectString
  , timeout = Nothing
  , withCredentials = False
  }

-- Json Encoding/Decoding
type alias Data =
  { jwt : Jwt
  , data : String
  }

decode_response : Decoder Response
decode_response =
  decode Data
    |> required "Jwt" string
    |> hardcoded "user"

encode_login : (String, String) -> Encode.Value
encode_login (username, password) =
  Encode.object
    [ ("username", Encode.string username)
    , ("password", Encode.string password)
    ]

-- Commands
authenticate : Cmd Msg
authenticate user =
  request user
    |> Http.send SendLogin

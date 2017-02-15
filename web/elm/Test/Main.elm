import Http
import HttpBuilder exposing (..)
import Json.Decode as Decode exposing (int, string, float, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Json.Encode as Encode
import Time

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- Config
url : String
url =
  "http://localhost:4000/api/v1/session"

-- Json Encoding/Decoding
decode : Decode.Decoder String
decode =
  Decode.at ["jwt"] string

encode_login : (String, String) -> Encode.Value
encode_login (username, password) =
  Encode.object
  [ ("session", Encode.object
      [ ("username", Encode.string username)
      , ("password", Encode.string password)
      ]
    )
  ]

-- Commands
authenticate : (String, String) -> Cmd Msg
authenticate cred =
  HttpBuilder.post url
    |> withJsonBody(encode_login cred)
    |> withTimeout(10 * Time.second)
    |> withExpect(Http.expectJson decode)
    |> send SendLogin

-- Model
type alias Model =
  { result : String
  , username : String
  , password : String
  }

init : (Model, Cmd Msg)
init =
  let
    model =
      { result = ""
      , username = "elarkham"
      , password = "password"
      }
  in
    (model, Cmd.none)

-- Update
type Msg
  = SendLogin (Result Http.Error String)
  | UsernameInput String
  | PasswordInput String
  | Submit

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SendLogin (Ok str) ->
      ({model | result = str}, Cmd.none)
    SendLogin (Err _) ->
      ({model | result = "Login Failed"}, Cmd.none)
    UsernameInput username ->
      ({model | username = username}, Cmd.none)
    PasswordInput password ->
      ({model | password = password}, Cmd.none)
    Submit ->
      (model, authenticate <| (model.username, model.password))

-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- View
view : Model -> Html Msg
view model =
  let
    username_input =
      label []
        [ text "Username: "
        , input [ type_ "text", onInput UsernameInput, value model.username ] []
        ]

    password_input =
      label []
        [ text "Password: "
        , input [ type_ "password", onInput PasswordInput, value model.password ] []
        ]

    submit_button =
       div []
        [ button [ onClick Submit ] [ text "Submit" ]
        ]

    login_validation =
      h6 [] [ text model.result ]
  in
    div []
      [ h2 [] [ text "Login" ]
      , username_input
      , password_input
      , submit_button
      , login_validation
      ]

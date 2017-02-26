module Main exposing (main)

import Types exposing (Msg(..))
import Model exposing (Model, init_model)
import Update exposing (update)
import Routing exposing (getRoute)
import View exposing (view)

import Navigation exposing (Location)

type alias Flags =
  { token : Maybe String }

init : Flags -> Location -> (Model, Cmd Msg)
init flags location =
  let
    route = getRoute flags.token location
    model = init_model flags.token route
  in
    (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

main : Program Flags Model Msg
main =
  Navigation.programWithFlags UrlChange
    { init = init
    , view = view
    , update = update
    , subscriptions = (always Sub.none)
    }

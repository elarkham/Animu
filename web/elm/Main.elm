module Main exposing (..)

import Types exposing (Msg(..))
import Model exposing (Model, init_model)
import Navigation exposing (Location)
import Routing exposing (Route)
import Update exposing (update)
import View exposing (view)

init : Location -> (Model, Cmd Msg)
init location =
  let
    current_route =
      Routing.parse_location location
  in
    (init_model current_route, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

main =
  Navigation.program UrlChange
    { init = init
    , view = view
    , update = update
    , subscriptions = (always Sub.none)
    }

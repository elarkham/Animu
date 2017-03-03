module Main exposing (main)

import Types exposing (Msg(..))
import Model exposing (Model, init_model)
import Update exposing (update)
import Routing exposing (parseLocation)
import View exposing (view)

import Navigation exposing (Location, modifyUrl)
import Window

type alias Flags =
  { token : Maybe String }

init : Flags -> Location -> (Model, Cmd Msg)
init flags location =
  let
    model =
      case flags.token of
        Just token ->
          init_model token True
        Nothing ->
          init_model "_" False
  in
    Routing.urlChange model location

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Window.resizes Resize
    ]

main : Program Flags Model Msg
main =
  Navigation.programWithFlags UrlChange
    { init = init
    , view = view
    , update = update
    , subscriptions = (always Sub.none)
    }

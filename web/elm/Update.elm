module Update exposing (..)

import Types exposing (Msg(..))
import Model exposing (Model)
import Routing (exposing parse_location)

import Pages.Login.Update

import Navigation exposing (Location)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UrlChange location ->
      let
        new_route =
          parse_location location
      in
        ({model | route = new_route}, Cmd.none)

    LoginMsg sub_msg ->
      let
        (new_model, cmd) =
          Pages.Login.Update.update sub_msg model
      in
        (new_model, Cmd.map LoginMsg cmd)

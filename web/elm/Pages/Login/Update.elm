module Pages.Login.Update exposing (..)

import Pages.Login.Types exposing (Msg(..))
import Pages.Login.Model exposing (Model)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UsernameInput location ->
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

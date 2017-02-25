module Update exposing (..)

import Types exposing (Msg(..), RootMsg(..))
import Model exposing (Model)
import Routing exposing (parse_location)

import Pages.Login.Update as Login
import OutMessage exposing (..)

-- Handle Page Updates
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
      Login.update sub_msg model.login_page
        |> mapComponent
          (\login_page -> {model | login_page = login_page})
        |> mapCmd LoginMsg
        |> evaluate updateRoot


-- Handle Global Updates
updateRoot : RootMsg -> Model -> ( Model, Cmd Msg )
updateRoot root_msg model =
  case root_msg of
    AcceptLogin session ->
      let
        model_ =
          { model
            | token = Just session.token
            , user = session.user
            , logged_in = True
          }
      in
        (model_, Cmd.none)

    _ ->
      (model, Cmd.none)

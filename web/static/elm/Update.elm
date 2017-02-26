module Update exposing (..)

import Types exposing (Msg(..), RootMsg(..))
import Model exposing (Model)
import Routing as R exposing (parseLocation, getRoute)
import Ports exposing (store)

import Pages.Login.Update as Login
import Navigation exposing (Location, newUrl)
import OutMessage exposing (..)

-- Handle Page Updates
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UrlChange location ->
      let
        _ = Debug.log "Location" location
        route = getRoute model.token location
      in
        updateRoute route model

    NewUrl url ->
        (model, newUrl url)

    LoginMsg sub_msg ->
      Login.update sub_msg model.login_page
        |> mapComponent
          (\login_page -> {model | login_page = login_page})
        |> mapCmd LoginMsg
        |> evaluate updateRoot


-- Handle Global Updates
updateRoot : RootMsg -> Model -> (Model, Cmd Msg)
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

        cmd =
          Cmd.batch
            [ store ("token", session.token)
            , newUrl "/"
            ]
      in
        (model_, cmd)

    _ ->
      (model, Cmd.none)

-- Handle Route Changes
updateRoute : R.Route -> Model -> (Model, Cmd Msg)
updateRoute route model =
  case route of
    _ ->
      (model, Cmd.none)

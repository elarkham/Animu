module Update exposing (..)

import Routing
import Rest exposing (Error(..))
import Types exposing (Msg(..), RootMsg(..))
import Model exposing (Model)
import Ports exposing (store, removeFromStorage)

import Pages.Login.Update as Login
import Pages.Home.Update as Home
import Navigation exposing (Location, newUrl, modifyUrl)
import OutMessage exposing (..)

{-| Handle Page Updates -}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UrlChange location ->
      let
        _ = Debug.log "Location" location
      in
        Routing.urlChange model location

    Resize size ->
      let
        model_ =
          {model | window = size}
      in
        (model_, Cmd.none)

    LoginMsg sub_msg ->
      Login.update sub_msg model.login_page
        |> mapComponent
          (\login_page -> {model | login_page = login_page})
        |> mapCmd LoginMsg
        |> evaluate updateRoot

    HomeMsg sub_msg ->
      Home.update sub_msg model.home_page
        |> mapComponent
          (\home_page -> {model | home_page = home_page})
        |> mapCmd HomeMsg
        |> evaluate updateRoot



{-| Handle Global Updates -}
updateRoot : RootMsg -> Model -> (Model, Cmd Msg)
updateRoot root_msg model =
  case root_msg of
    AcceptLogin session ->
      let
        model_ =
          { model
            | token = session.token
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

    HandleError err ->
      handleError model err

    _ ->
      (model, Cmd.none)

{-| Handle Potential Http Errors -}
handleError : Model -> Error -> (Model, Cmd Msg)
handleError model err =
  case err of
    Forbidden resp ->
      let
        model_ = {model | logged_in = False}
        cmd =
          Cmd.batch
            [ removeFromStorage("token")
            , modifyUrl("#/login")
            ]
      in
        (model_, cmd)

    _ ->
      (model, Cmd.none)

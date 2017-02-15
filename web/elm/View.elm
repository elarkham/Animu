module View exposing (..)

import Html exposing (Html, text, main_)
import Types exposing (Msg(..))
import Models exposing (Model)
import Routing exposing (Route(..))

import Pages.Home.View exposing (home)
import Pages.Login.View exposing (login)
import Components.Navbar exposing (navbar)

import String exposing (isEmpty)

view : Model -> Html Msg
view model =
  let
    auth_model =
    if isEmpty model.jwt then
      {model | route = Login}
    else
      model
  in
    main_ [] page(auth_model)

page : Model -> Html Msg
page model =
  case model.route of
    Login   -> login model
    NoRoute -> err404 model
    _       -> content model

content : Model -> Html Msg
content model =
  let
    article =
    case model.route of
      Home -> home model
  in
    [ navbar
    , article
    ]

err404 : Model -> Html Msg
err404 model =
  [ text "404" ]

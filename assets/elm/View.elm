module View exposing (..)

import Html exposing (Html, text, main_, div)
import Html.Attributes exposing (..)

import Types exposing (Msg(..), Route(..))
import Model exposing (Model)

import Pages.Home.View exposing (home)
import Pages.Login.View exposing (login)
import Components.Navbar exposing (navbar)

view : Model -> Html Msg
view model =
  let
    _ = Debug.log "State" model
  in
    main_ [id "root-container"] [ page(model) ]

page : Model -> Html Msg
page model =
  case model.route of
    Login   -> Html.map LoginMsg (login model.login_page)
    NoRoute -> err404 model
    _       -> content model

content : Model -> Html Msg
content model =
  let
    article =
    case model.route of
      Home -> home model.home_page
      _ -> text "problem"
  in
    div []
      [ navbar
      , div [id "page-container"] [article]
      ]

err404 : Model -> Html Msg
err404 model =
  text "404"

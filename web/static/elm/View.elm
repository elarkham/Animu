module View exposing (..)

import Html exposing (Html, text, main_, div)
import Types exposing (Msg(..))
import Model exposing (Model)
import Routing exposing (Route(..))

-- import Pages.Home.View exposing (home)
import Pages.Login.View exposing (login)
-- import Components.Navbar exposing (navbar)

view : Model -> Html Msg
view model =
  let
    model_ =
    if model.token == Nothing then
      {model | route = Login}
    else
      model
  in
    main_ [] [ page(model_) ]

page : Model -> Html Msg
page model =
  case model.route of
    Login   -> Html.map LoginMsg (login model)
    NoRoute -> err404 model
    _       -> content model

content : Model -> Html Msg
content model =
  let
    article =
    case model.route of
      Home -> text "Welcome Home"
      _ -> text "problem"
  in
    div []
      [ div [] []
      , article
      ]

err404 : Model -> Html Msg
err404 model =
  text "404"

module Pages.Login.View exposing (..)

import Types exposing (Msg(..))
import Pages.Login.Types as Login
import Pages.Login.Models exposing (User, Jwt)
import Pages.Login.Commands

import Html exposing ()

view : Model -> Html Msg
view model =
  let
    username_input =
      label [ for "username-input" ]
        [ input [ type_ "text", onInput Login.UsernameInput ]
        , text "Username: "
        ]

    password_input =
      label []
        [ input [ type_ "password", onInput Login.PasswordInput ]
        , text "Password: "
        ]

    submit_button =
       div []
        [ button [ onClick Login.Submit ] [ text "Submit" ]
        ]

    login_validation =
      h6 [] [ text model.login_page.error ]
  in
    [ div []
      [ h2 [] [ text "Login" ]
      , username_input
      , password_input
      , submit_button
      , login_validation
      ]
    ]

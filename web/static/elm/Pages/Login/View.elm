module Pages.Login.View exposing (..)

import Model exposing (Model)
import Pages.Login.Types exposing (Msg(..))

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

login : Model -> Html Msg
login model =
  let
    login_model = model.login_page
    username_input =
      label []
        [ text "Username: "
        , input [ type_ "text"
                , onInput UsernameInput
                , value login_model.username ] []
        ]

    password_input =
      label []
        [ text "Password: "
        , input [ type_ "password"
                , onInput PasswordInput
                , value login_model.password ] []
        ]

    submit_button =
       div []
        [ button [ onClick Submit ] [ text "Submit" ]
        ]

    login_validation =
      h6 [] [ text login_model.error ]
  in
    div []
      [ h2 [] [ text "Login" ]
      , username_input
      , password_input
      , submit_button
      , login_validation
      ]


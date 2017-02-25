module Pages.Login.Update exposing (..)

import Types exposing (RootMsg(..))
import Rest exposing (Error(..))

import Pages.Login.Model exposing (Model)
import Pages.Login.Types exposing (Msg(..))
import Pages.Login.Rest exposing (authenticate, errorDecoder)

import Json.Decode exposing (decodeString)

update : Msg -> Model -> (Model, Cmd Msg, RootMsg)
update msg model =
  case msg of
    UsernameInput username ->
      let
        model_ =
          { model | username = username }
      in
        (model_, Cmd.none, NoOp)

    PasswordInput password ->
      let
        model_ =
          { model | password = password }
      in
        (model_, Cmd.none, NoOp)

    SendLogin (Ok session) ->
        (model, Cmd.none, AcceptLogin session)

    SendLogin (Err (UnprocessableEntity resp)) ->
      let
        error =
          case decodeString errorDecoder resp.body of
            (Ok value) -> value
            (Err _) -> "Failed To Decode Response"

        model_ =
          { model | error = error }
      in
        (model_, Cmd.none, NoOp)

    SendLogin (Err Timeout) ->
      let
        model_ =
          { model | error = "Cannot Connect To Host" }
      in
        (model_, Cmd.none, NoOp)


    SendLogin (Err NetworkError) ->
      let
        model_ =
          { model | error = "Cannot Connect To Host" }
      in
        (model_, Cmd.none, NoOp)

    SendLogin (Err _) ->
      let
        model_ =
          { model | error = "Login Failed" }
      in
        (model_, Cmd.none, NoOp)

    Submit ->
      let
        cmd = authenticate <| (model.username, model.password)
      in
        (model, cmd, NoOp)



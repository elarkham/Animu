module Routing exposing (..)

import Model exposing (Model)
import Types exposing (Msg(..), Route(..))

import Pages.Home.Rest as Home

import Navigation exposing (Location, modifyUrl)
import UrlParser exposing (..)
import Jwt exposing (decodeToken, isExpired)

router : Parser (Route -> a) a
router =
  oneOf
    [ map Login (s "login")
    , map Home top
    ]

parseLocation : Location -> Route
parseLocation location =
  case (parseHash router location) of
    Just route -> route
    Nothing -> NoRoute

urlChange : Model -> Location -> (Model, Cmd Msg)
urlChange model location =
  let
    route = parseLocation location
  in
    case (model.logged_in || route == Login) of
      True ->
        loadRoute {model | route = route}

      False ->
        (model, modifyUrl "#/login")

-- Handle Route Changes
loadRoute : Model -> (Model, Cmd Msg)
loadRoute model =
  let
    _ = Debug.log "Updating Route To" model.route

    route = model.route
  in
  case route of
    Home ->
      let
        cmd =
          Cmd.batch
            [ Home.getLastWatched model.token
            , Home.getWeeklyReleases model.token
            , Home.getRecentAdditions model.token
            ]
      in
        (model, Cmd.map HomeMsg cmd)

    _ ->
      (model, Cmd.none)

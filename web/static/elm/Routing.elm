module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)

type Route
  = Login
  | Home
  | NoRoute

router : Parser (Route -> a) a
router =
  oneOf
    [ map Login (s "login")
    , map Home top
    ]

parseLocation : Location -> Route
parseLocation location =
  case (parseHash router location) of
    Just route ->
      route

    Nothing ->
      NoRoute

-- Redirect to Login Page if not logged in
getRoute : Maybe String -> Location -> Route
getRoute token location =
  case token of
    Just _ ->
      parseLocation location

    Nothing ->
      Login



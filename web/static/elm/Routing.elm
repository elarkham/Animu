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

parse_location : Location -> Route
parse_location location =
  case (parseHash router location) of
    Just route ->
      route

    Nothing ->
      NoRoute

module Types exposing (..)

import Pages.Login.Types exposing (..)
import Navigation exposing (Location)

type Msg
  = UrlChange Location
  | LoginMsg Pages.Login.Types.Msg


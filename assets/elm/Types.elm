module Types exposing (..)

import Pages.Login.Types as Login
import Pages.Home.Types as Home
import Rest
-- import Models.User as User

import Navigation exposing (Location)
import Window exposing (Size)

type Route
  = Login
  | Home
  | NoRoute

type RootMsg
  = NoOp
  | AcceptLogin Login.Session
  | HandleError Rest.Error

type Msg
  = UrlChange Location
  | Resize Size
  | LoginMsg Login.Msg
  | HomeMsg Home.Msg

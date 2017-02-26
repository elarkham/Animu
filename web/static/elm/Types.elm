module Types exposing (..)

import Pages.Login.Types as Login
-- import Models.User as User

import Navigation exposing (Location)

type RootMsg
  = NoOp
  | AcceptLogin Login.Session

type Msg
  = UrlChange Location
  | NewUrl String
  | LoginMsg Login.Msg

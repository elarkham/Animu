module Model exposing (..)

import Routing exposing (Route)

import Pages.Login.Model as Login
import Models.User as User

type alias Model =
  { route : Route
  , token : Maybe String
  , logged_in : Bool
  , user : User.Model
  , login_page: Login.Model
  }

init_model : Route -> Model
init_model route =
  { route = route
  , token = Nothing
  , logged_in = False
  , user = User.init_model
  , login_page = Login.init_model
  }
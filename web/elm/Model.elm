module Model exposing (..)

import Routing exposing (Route)
import Pages.Login.Model as Login

type alias Model =
  { route : Route
  , token : Maybe String
  , logged_in : Bool
  , login_page: Login.Model
  }

init_model : Route -> Model
init_model route =
    { route = route
    , token = Nothing
    , logged_in = False
    , login_page = Login.init_model
    }

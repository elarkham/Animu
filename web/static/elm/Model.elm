module Model exposing (..)

import Types as T exposing (Route)

import Pages.Login.Model as Login
import Pages.Home.Model as Home
import Models.User as User

type alias Model =
  { route : Route
  , token : String
  , logged_in : Bool
  , user : User.Model
  , login_page: Login.Model
  , home_page: Home.Model
  }

init_model : String -> Bool -> Model
init_model token logged_in  =
  { route = T.Home
  , token = token
  , logged_in = logged_in
  , user = User.init_model
  , login_page = Login.init_model
  , home_page = Home.init_model
  }

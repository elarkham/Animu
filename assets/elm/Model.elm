module Model exposing (..)

import Types as T exposing (Route)

import Pages.Login.Model as Login
import Pages.Home.Model as Home
import Models.User as User

import Window

type alias Model =
  { route : Route
  , token : String
  , logged_in : Bool
  , user : User.Model
  , window: Window.Size
  , login_page: Login.Model
  , home_page: Home.Model
  }

init_model : String -> Bool -> Window.Size -> Model
init_model token logged_in window =
  { route = T.Home
  , token = token
  , logged_in = logged_in
  , user = User.init_model
  , window = window
  , login_page = Login.init_model
  , home_page = Home.init_model
  }

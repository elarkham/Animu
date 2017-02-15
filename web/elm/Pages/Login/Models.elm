module Pages.Login.Models exposing (..)

type alias Model =
  { username : String
  , password : String
  , error : String
  }

init_model : Model
init_model =
    { username = ""
    , password = ""
    , error = ""
    }

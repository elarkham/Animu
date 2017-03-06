module Pages.Login.Types exposing (..)

import Models.User as User
import Rest

type Msg
  = SendLogin (Result Rest.Error Session)
  | UsernameInput String
  | PasswordInput String
  | Submit

-- Session Model
type alias Session =
  { token : String
  , user : User.Model
  }



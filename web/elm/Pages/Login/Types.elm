module Pages.Login.Types exposing (..)

import Http

type Msg
  = UsernameInput String
  | PasswordInput String
  | Submit


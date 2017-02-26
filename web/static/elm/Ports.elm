port module Ports exposing (..)

-- Save Key/Value to Local Storage
port store : (String, String) -> Cmd msg

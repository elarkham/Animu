port module Ports exposing (..)

-- Save Key/Value to Local Storage
port store : (String, String) -> Cmd msg

-- Remove Key/Value from Local Storage
port removeFromStorage : String -> Cmd msg


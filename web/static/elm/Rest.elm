module Rest exposing (..)

import Http exposing (Response)
import HttpBuilder exposing (RequestBuilder, withHeader, withTimeout)
import Json.Decode as Decode exposing (int, string, float, Decoder)
import Json.Decode.Pipeline as Pipe exposing (required)
-- import Json.Encode as Encode
import Navigation exposing (newUrl)
import Task
import Time

-- Config

url : String
url =
  "/api/v1/"

assets : String
assets =
  "/assets/"

-- Http Error Wrapper

type Error
  = Forbidden (Response String)
  | Unauthorized (Response String)
  | UnprocessableEntity (Response String)
  | BadUrl String
  | Timeout
  | NetworkError
  | HttpError Http.Error

-- Aliases

type alias ResultHandler msg a = (Result Error a -> msg)
type alias Request a = RequestBuilder a

-- HttpBuilder Helpers

{-| Send Http request with token -}
send : String -> ResultHandler msg a -> Request a -> Cmd msg
send token resultHandler request =
  let
    _ = Debug.log "Sending" request
  in
  request
    |> withHeader "Authorization" token
    |> withTimeout(10 * Time.second)
    |> HttpBuilder.toTask
    |> Task.mapError wrapError
    |> Task.attempt resultHandler

{-| Send raw Http request -}
sendRaw : ResultHandler msg a -> Request a -> Cmd msg
sendRaw resultHandler request =
  request
    |> HttpBuilder.toTask
    |> Task.mapError wrapError
    |> Task.attempt resultHandler


{-| Wrap Http Errors Into Custom Type-}
wrapError : Http.Error -> Error
wrapError err =
  case err of
    Http.BadStatus resp ->
      if resp.status.code == 401 then
        Unauthorized resp

      else if resp.status.code == 403 then
        Forbidden resp

      else if resp.status.code == 422 then
        UnprocessableEntity resp

      else
        HttpError err

    Http.BadUrl string -> BadUrl string
    Http.Timeout -> Timeout
    Http.NetworkError -> NetworkError
    _ -> HttpError err



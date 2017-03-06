module Components.Series exposing (..)

import Models.Series as Series
import Types exposing (Msg(..))
import Rest exposing (assets)

import Html exposing (..)
import Html.Attributes exposing (..)
-- import Html.Events exposing (..)
import String exposing (dropRight)

poster : Series.Model -> Html Msg
poster s =
  let
    canon_title = s.canon_title
    poster_image = assets ++ s.directory ++ s.poster_image.large
  in
    div [class "poster-card"]
      [ img [src poster_image, title canon_title, height 300 ] [] ]

card : Series.Model -> Html Msg
card s =
  let
    en_title = s.titles.en
    canon_title = s.canon_title
    poster_image = assets ++ s.directory ++ s.poster_image.large
    synopsis = trimSynopsis s.synopsis
  in
    div [class "info-card"]
      [ img [src poster_image, height 300 ] []
      , div [class "card-content"]
          [ h4 [class "card-title"] [text canon_title]
          , h5 [class "card-subtitle"] [text en_title]
          , p [class "card-text"] [text synopsis]
          ]
      ]

trimSynopsis : String -> String
trimSynopsis s =
  let
    length = (String.length s) - 365
    synopsis =
      case (length < 0) of
        False ->
          (dropRight length s) ++ "..."
        True -> s
  in
   synopsis

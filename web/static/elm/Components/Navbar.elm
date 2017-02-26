module Components.Navbar exposing (..)

-- import Model exposing (Model)
import Types exposing (Msg(..))

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

navbar : Html Msg
navbar =
  let
    trending =
      li [] [ a [href "#/trending"] [text "Trending"] ]

    seasonal =
      li [] [ a [href "#/seasonal"] [text "Seasonal"] ]

    archive =
      li [] [ a [href "#/archive"] [text "Archive"] ]

    manage =
      li [] [ a [href "#/manage"] [text "Manage"] ]
  in
    nav []
      [ h1 [] [ a [href "#/"] [text "ANIMU"] ]
      , ul []
          [ trending
          , seasonal
          , archive
          , manage
          ]
      ]



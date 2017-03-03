module Components.Navbar exposing (..)

-- import Model exposing (Model)
import Types exposing (Msg(..))

import Html exposing (..)
import Html.Attributes exposing (..)
-- import Html.Events exposing (..)

navbar : Html Msg
navbar =
  let
    trending =
      li [class "menu-item"] [ a [href "#/trending"] [text "Trending"] ]

    seasonal =
      li [class "menu-item"] [ a [href "#/seasonal"] [text "Seasonal"] ]

    archive =
      li [class "menu-item"] [ a [href "#/archive"] [text "Archive"] ]

    manage =
      li [class "menu-item"] [ a [href "#/manage"] [text "Manage"] ]

    history =
      li [class "menu-item"] [ a [href "#/history"] [text "History"] ]

    queue =
      li [class "menu-item"] [ a [href "#/queue"] [text "Queue"] ]
  in
    nav [id "sidebar"]
      [ h1 [class "logo"] [ a [href "#/"] [text "ANIMU"] ]
      , ul [class "menu-list"]
          [ trending
          , seasonal
          , archive
          , manage
          , history
          , queue
          ]
      ]



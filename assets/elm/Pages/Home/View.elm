module Pages.Home.View exposing (home)

import Types exposing (Msg(..))
import Pages.Home.Types as Home
import Pages.Home.Model exposing (Model)

-- import Models.Series as Series
-- import Models.Episode as Episode
import Components.Series as C
-- import Components.Episode exposing (thumbnail)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List

home : Model -> Html Msg
home model =
  let
    last_watched =
      section [id "last-watched", class "content-box"]
        [ h2 [class "content-box-header"] [text "Last Watched"]
        , div [class "content-box-body"] (List.map C.poster model.last_watched)
        ]

    weekly_releases =
      section [id "weekly-releases", class "content-box"]
        [ h2 [class "content-box-header"] [text "Weekly Releases"]
--        , div [] map(thumbnail, model.weekly_releases)
        ]

    recently_added =
      section [id "recently-added", class "content-box"]
        [ h2 [class "content-box-header"] [text "Recently Added"]
        , div [class "content-box-body"] (List.map C.card model.recent_additions)
        ]
  in
    div [id "home"]
      [ last_watched
      , weekly_releases
      , recently_added
      ]

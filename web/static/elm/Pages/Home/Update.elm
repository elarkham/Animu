module Pages.Home.Update exposing (..)

import Types exposing (RootMsg(..))
-- import Rest exposing (Error(..))

import Pages.Home.Model exposing (Model)
import Pages.Home.Types exposing (Msg(..))

update : Msg -> Model -> (Model, Cmd Msg, RootMsg)
update msg model =
  case msg of

    -- Last Watched

    GetLastWatched (Ok lw) ->
      let
        model_ =
          {model | last_watched = lw}
      in
        (model_, Cmd.none, NoOp)

    GetLastWatched (Err err) ->
      (model, Cmd.none, HandleError err)

    -- Weekly Releases

    GetWeeklyReleases (Ok wr) ->
      let
        model_ =
          {model | weekly_releases = wr}
      in
        (model_, Cmd.none, NoOp)

    GetWeeklyReleases (Err err) ->
      (model, Cmd.none, HandleError err)

    -- Trending

    GetRecentAdditions (Ok rr) ->
      let
        model_ =
          {model | recent_additions = rr}
      in
        (model_, Cmd.none, NoOp)

    GetRecentAdditions (Err err) ->
      (model, Cmd.none, HandleError err)



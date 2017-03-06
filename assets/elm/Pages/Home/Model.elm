module Pages.Home.Model exposing (..)

import Models.Series as Series
import Models.Episode as Episode

type alias Model =
  { last_watched : List Series.Model
  , weekly_releases : List Episode.Model
  , recent_additions: List Series.Model
  }

init_model : Model
init_model =
    { last_watched = []
    , weekly_releases = []
    , recent_additions = []
    }

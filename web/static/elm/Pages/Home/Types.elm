module Pages.Home.Types exposing (..)

import Models.Series as Series
import Models.Episode as Episode
import Rest

type Msg
  = GetLastWatched (Result Rest.Error SeriesData)
  | GetWeeklyReleases (Result Rest.Error EpisodeData)
  | GetRecentAdditions (Result Rest.Error SeriesData)

type alias SeriesData = List Series.Model
type alias EpisodeData = List Episode.Model

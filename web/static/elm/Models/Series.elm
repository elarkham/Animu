module Models.Series exposing (..)

import Json.Decode as Decode exposing (int, string, float, bool, list, Decoder)
import Json.Decode.Pipeline as Pipe exposing (required, optional, hardcoded)

type alias Model =
  { canon_title : String
  , titles : Titles
  , synopsis : String
  , slug : String

  , cover_image : CoverImage
  , poster_image : PosterImage
--  , gallery : String

  , trailers : List String
  , tags : List String
  , genres : List String

  , age_rating : String
  , nsfw : Bool

  , season_number : Int
  , episode_count : Int
  , episode_length : Int

  , kitsu_rating : Float
  , kitsu_id : String

  , regex : String
  , subgroup : String
  , quality : String
  , rss_feed : String
  , watch : Bool

  , directory : String

--  , started_airing_date : String
--  , finished_airing_data : String
  }

type alias Titles =
  { en : String
  , en_jp : String
  , ja_en : String
  , ja_jp : String
  }

type alias CoverImage =
  { large : String
  , original : String
  , small : String
  }

type alias PosterImage =
  { large : String
  , medium : String
  , original : String
  , small : String
  }

init_model : Model
init_model =
  { canon_title = "_"
  , titles = {en = "_", en_jp = "_", ja_en = "_", ja_jp = "_"}
  , synopsis = "___"
  , slug = "XXXX"

  , cover_image = {large = "", original = "", medium = ""}
  , poster_image = {large = "", medium = "", original = "", small = ""}
--  , gallery : "_"

  , trailers = []
  , tags = ["blank"]
  , genres = []

  , age_rating = "_"
  , nsfw = False

  , season_number = -1
  , episode_count = -1
  , episode_length = -1

  , kitsu_rating = 0.0
  , kitsu_id = "XXXX"

  , regex = "_"
  , subgroup = "_"
  , quality = "_"
  , rss_feed = "_"
  , watch = False

  , directory : "XXXX"

--  , started_airing_date : "_"
--  , finished_airing_data : "_"
  }

decode : Decoder Model
decode =
  let
    m = init_model
  in
  Pipe.decode Model
    |> required "canon_title" string
    |> optional "titles" titleDecoder m.titles
    |> optional "synopsis" string m.synopsis
    |> required "slug" string
    |> optional "cover_image" coverDecoder m.cover_image
    |> optional "poster_image" posterDecoder m.poster_image
    |> optional "trailers" (list string) m.trailers
    |> optional "tags" (list string) m.tags
    |> optional "genres" (list string) m.genres
    |> optional "age_rating" string m.age_rating
    |> optional "nsfw" bool m.nsfw
    |> optional "season_number" int m.season_number
    |> optional "episode_count" int m.episode_count
    |> optional "episode_length" int m.episode_length
    |> optional "kitsu_rating" float m.kitsu_rating
    |> optional "kitsu_id" string m.kitsu_id
    |> optional "regex" string m.regex
    |> optional "subgroup" string m.subgroup
    |> optional "quality" string m.quality
    |> optional "rss_feed" string m.rss_feed
    |> optional "watch" bool m.watch
    |> required "directory" string

titleDecoder : Decoder Titles
titleDecoder =
  let
    m = init_model.titles
  in
  Pipe.decode Titles
    |> optional "en" string m.en
    |> optional "en_jp" string m.en_jp
    |> optional "ja_jp" string m.ja_jp

coverDecoder : Decoder CoverImage
coverDecoder =
  let
    m = init_model.cover_image
  in
  Pipe.decode CoverImage
    |> optional "large" string m.large
    |> optional "original" string m.original
    |> optional "small" string m.small

posterDecoder : Decoder PosterImage
posterDecoder =
  let
    m = init_model.poster_image
  in
  Pipe.decode CoverImage
    |> optional "large" string m.large
    |> optional "medium" string m.medium
    |> optional "original" string m.original
    |> optional "small" string m.small


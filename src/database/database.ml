(* Databases utils *)

open Soup
open Crawler

type t = {
  name                  : string;
  url_games             : string;
  games_list_crawler    : t_element list;
  pages_count           : int;
  slug_from_item        : element node -> string;
  src_from_item         : element node -> string;
  icon_from_page        : string -> Assets.t option;
  background_from_page  : string -> Assets.t option;
  logo_from_page        : string -> Assets.t option;
  file                  : string;
} ;;

let make
  ( name                       : string                     )
  ( url_games                  : string                     )
  ( games_page_crawler         : t_element list             )
  ( pages_count                : int                        )
  ( slug_from_item             : element node -> string     )
  ( src_from_item              : element node -> string     )
  ( icon_from_page             : string -> Assets.t option  )
  ( background_from_page       : string -> Assets.t option  )
  ( logo_from_page             : string -> Assets.t option  ) : t =
  { name                  = name
  ; url_games             = url_games
  ; games_list_crawler    = games_page_crawler
  ; pages_count           = pages_count
  ; slug_from_item        = slug_from_item
  ; src_from_item         = src_from_item
  ; icon_from_page        = icon_from_page
  ; background_from_page  = background_from_page
  ; logo_from_page        = logo_from_page
  ; file                  = (Config.db_path ^ (String.lowercase_ascii name) ^ ".json") }
;;

let soup (db : t) (page: int) : soup node = Lwt_main.run (body (db.url_games ^ (string_of_int page))) |> Soup.parse ;;

let games_number (db : t) : int =
  let pages : int = db.pages_count in
  let rec aux (i : int) : int =
    if i = pages + 1 then 0
    else
      let res : int = (soup db i) |> browse_elements db.games_list_crawler |> count
      in res + (aux (i + 1))
  in aux 1 ;;

let icon (src : string) (db : t) : Assets.t option = db.icon_from_page src ;;
let background (src : string) (db : t) : Assets.t option = db.background_from_page src ;;
let logo (src : string) (db : t) : Assets.t option = db.logo_from_page src ;;
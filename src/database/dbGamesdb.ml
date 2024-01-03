open Soup
open Soup.Infix
open Crawler
open Assets
open Database

(* === Basic crawling configuration === *)

let src_base_url : string = "https://gamesdb.launchbox-app.com" ;;
let games_url : string = "https://gamesdb.launchbox-app.com/platforms/games/25-nintendo-64/page/" ;;

let games_crawler : t_element list =
  [
    Element "html" ;
    Element "body" ;
    Element "div.container.p-t-md" ;
    Elements "div.list-item-wrapper"
  ] ;;

let script_crawler : t_element list =
  [
    Element "html" ;
    Element "body" ;
    Elements "script" ;
  ] ;;

let retrieve_param (param : string) (content : string) : string =
  let open Str in
  let regex = regexp (param ^ ": \\([0-9]+\\),") in
  let _ = search_forward regex content 0 in matched_group 1 content ;;

let pages_count : int =
  Lwt_main.run (body (games_url ^ "1")) |> Soup.parse 
  |> browse_elements script_crawler |> last |> require
  |> Soup.pretty_print |> retrieve_param "totalPages" |> int_of_string ;;

(* === Item crawling configuration === *)

let medias_crawler : t_element list =
  [
    Element "div.container.p-t-md" ;
    Element "div.container.m-y-md" ;
    Element "div.image-list" ;
    Elements "a[data-footer]"
  ] ;;

(* === Item crawling configuration === *)

let slug_from_item (item : element node) : string =
  item $ "a.list-item"
  |> select_one "div.row" |> require
  |> select_one "div.col-sm-10" |> require
  |> select_one "h3" |> require
  |> R.leaf_text
  |> Standardizer.slugify
;;

let format_media_page_src (src : string) : string =
  let regex = Str.regexp "details" in
  Str.replace_first regex "images" src
;;

let src_from_item (item : element node) : string =
  item $ "a.list-item" |> R.attribute "href" |> (^) src_base_url |> format_media_page_src
;;

(* === Medias crawling === *)

let medias_list (url : string) : element node list =
  Lwt_main.run (body url) |> Soup.parse
  |> browse_elements medias_crawler |> to_list ;;

let get_region_key (a_media : element node) : int =
  let open Str in
  let data_footer : string = a_media |> R.attribute "data-footer" in
  let regex = regexp "data-regionkey='\\([0-9]+?\\)'" in
  try
    let _ = search_forward regex data_footer 0 in
    let res : int option = (matched_group 1 data_footer) |> int_of_string_opt in
    match res with
    | None -> 0
    | Some n -> n
  with Not_found -> 0
;;

let get_imagetype_key (a_media : element node) : int =
  let open Str in
  let data_footer : string = a_media |> R.attribute "data-footer" in
  let regex = regexp "data-imagetypekey='\\([0-9]+\\)'" in
  let _ = search_forward regex data_footer 0
  in let res : int option =  (matched_group 1 data_footer) |> int_of_string_opt
  in match res with
  | None -> 0
  | Some n -> n
;;

let match_region (a_media : element node) (region : string) : bool =
  let region_key : int = get_region_key a_media in
  match region_key with
  | 0  -> String.equal region "All" (* Specific to wallpapers *)
  | 1  -> String.equal region "US"
  | 4  -> String.equal region "EU"
  | 6  -> String.equal region "W"
  | 12  -> String.equal region "FR"
  | 13  -> String.equal region "G"
  | 18  -> String.equal region "JP"
  | _  -> false
;;

let match_asset_type (a_media : element node) (asset_type : t_asset_type) : bool =
  let imagetype_key : int = get_imagetype_key a_media in
  match imagetype_key with
  | 1 -> asset_type = BG
  | 4 -> asset_type = BG
  | 3 -> asset_type = LOGO 
  | _ -> false
;;

(* ICON *)
let icon (src : string) : Assets.t option = let _ = src in None ;;

(* BACKGROUND *)

(* Returns the wallpaper if exists *)
let wallpaper (medias : element node list) : Assets.t option =
  medias |> List.find_opt (fun n -> (match_asset_type n BG) && (match_region n "All")) |> function
  | None -> None
  | Some n -> let url : string = n |> R.attribute "href" in Some (Assets.make BG url) ;;
  
(* Returns the 2D cover if exists *)
let cover2d (medias : element node list) (region : string) : Assets.t option =
  let rec aux (nodes : element node list) : Assets.t option =
    match nodes with
    | [] -> None
    | hd::tl ->
      if (match_asset_type hd BG) && (match_region hd region) then
        let url : string = hd |> R.attribute "href" in Some (Assets.make BG url)
      else aux tl
  in aux medias ;;

let background (src : string) : Assets.t option = (
  let medias : element node list = medias_list src in
  let bg : Assets.t option = wallpaper medias in
  match bg with
  | None ->
    let rec aux (regions : string list) : Assets.t option =
      match regions with
      | [] -> None
      | hd::tl ->
        match cover2d medias hd with
        | None -> aux tl
        | Some a -> Some a
    in aux ["EU"; "FR"; "W"]
  | Some bg -> Some bg
) ;;

(* LOGO *)
let logo (src : string) : Assets.t option = (
  let medias : element node list = medias_list src in
  let logo_list : element node list = medias |> List.filter (fun n -> match_asset_type n LOGO) in
  let rec aux (regions : string list) : Assets.t option =
    match regions with
    | [] -> None
    | hd::tl -> match (List.find_opt (fun n -> match_region n hd) logo_list) with
      | None -> aux tl
      | Some n -> n |> R.attribute "href" |> fun u -> Some (Assets.make LOGO u)
  in aux ["FR"; "EU"; "W" ; "All" ; "US"]
) ;;

(* Database handler creation *)

let db : Database.t =
  let pages_number : int = pages_count in
  make
    "GamesDB"
    games_url
    games_crawler
    pages_number
    slug_from_item
    src_from_item
    icon
    background
    logo ;;

open Soup
open Soup.Infix
open Crawler
open Assets
open Database

(* === Basic crawling configuration === *)

let src_base_url : string = "https://db.hfsplay.fr" ;;
let games_url : string = "https://db.hfsplay.fr/games/missing?value=media&system_id=32765&page=" ;;

let games_crawler : t_element list =
  [
    Element "#container";
    Element "#main-container";
    Element "div.container" ;
    Element "#items-list";
    Elements "div.item"
  ] ;;

let paginator_crawler : t_element list =
  [
    Element "#container";
    Element "#main-container";
    Element "div.container" ;
    Element "div.pagination";
    Element "div.paginate";
    Element "div.menu";
    Elements "div.item"
  ] ;;


let pages_count : int =
  Lwt_main.run (body (games_url ^ "1")) |> Soup.parse
  |> browse_elements paginator_crawler |> count

(* Medias crawling configuration *)
let medias_crawler : t_element list =
  [
    Element "div#container" ;
    Element "div#main-container" ;
    Element "div.stackable" ;
    Element "div.divided" ;
    Element "div#medias" ;
    Element "div.ui.padded.grid"
  ] ;;

(* === Item crawling configuration === *)

(* Formats titles contained in HTML element (only used for this soup) *)
let flatify (title : string) : string =
  let open Str in
  let reg = regexp "\n + +" in
  let res : string = global_replace reg "" title in Standardizer.slugify res
;;

let slug_from_item (item : element node) : string =
  match item $? "a.content" with
  | Some x -> x |> select_one "div.header" |> require |> R.leaf_text |> flatify
  | None -> "No title" ;;

let src_from_item (item : element node) : string =
  match item $? "a[href]" with
  | Some x -> x |> R.attribute "href" |> (^) src_base_url
  | None -> "No source" ;;

(* === Medias crawling === *)

(* Returns the image url from style attribute
   Example:
      this:     <div class="ui image gallery-item imgload" style="background:url('/files/toto.jpg');"></div>
      becomes:  /files/toto.jpg
*)
let get_img_url (node : string) : string =
  let open Str in
  let reg = regexp "background:url('\\([^']+\\)');" in
  let _ = search_forward reg node 0 in
    matched_group 1 node

let medias (url : string) : element node =
  Lwt_main.run (body url) |> Soup.parse |> browse_element medias_crawler ;;

(* ICON *)
let icon (src : string) : Assets.t option =
  let page : element node = medias src in
  let icon_container : element node option = page $? "div#medias-wheel" in
    match icon_container with
    | None -> None
    | Some n ->
      let icons : element node list = n $$ "div.gallery-item-container" |> to_list in
        let rec aux (nodes : element node list) : Assets.t option =
          match nodes with
          | [] -> None
          | hd::tl ->
            match (hd $? "div.subheader") with
            | None -> aux tl
            | Some sub ->
              let isRound : bool = sub |> R.leaf_text |> String.equal "round" in
              if isRound then
                let node : element node = (hd $ "div.gallery-item") in
                let url : string = (Soup.pretty_print node) |> get_img_url in Some (Assets.make ICON (src_base_url ^ url));
              else aux tl
        in aux icons
;;

(* BACKGROUND *)

(* Returns the wallpaper if exists *)
let wallpaper (page : element node) : Assets.t option =
  let container : element node option = page $? "div#medias-wallpaper" in
  match container with
  | None -> None
  | Some n ->
    let wallpaper : element node = n $ "div.wallpaper" in
    let url : string = (Soup.pretty_print (wallpaper $ "div.gallery-item")) |> get_img_url
    in Some (Assets.make BG (src_base_url ^ url))
;;

(* Returns the 2D cover if exists *)
let cover2d (page : element node) (region : string) : Assets.t option =
  let cover_container: element node option = page $? "div#medias-cover2d" in
  match cover_container with
  | None -> None
  | Some n ->
    let covers: element node list = n $$ "div.cover2d" |> to_list in
      let rec aux (nodes : element node list) : Assets.t option =
        match nodes with
        | [] -> None
        | hd::tl ->
          let reg : string = hd $ "span[title]" |> R.attribute "title"
          and face : string = hd $ "div.subheader" |> R.leaf_text in
            if (String.equal reg region) && (String.equal face "front") then
              let node : element node = (hd $ "div.gallery-item") in
              let url : string = (Soup.pretty_print node) |> get_img_url in
                Some (Assets.make BG (src_base_url ^ url));
            else aux tl
      in aux covers
;;

let background (src : string) : Assets.t option =
  let page : element node = medias src in
  let bg : Assets.t option = wallpaper page in
  match bg with
  | None ->
    let rec aux (regions : string list) : Assets.t option =
      match regions with
      | [] -> None
      | hd::tl ->
        match cover2d page hd with
        | None -> aux tl
        | Some a -> Some a
    in aux ["Region PAL"; "Region WORLD"]
  | Some bg -> Some bg
;;

(* LOGO *)
let logo (src : string) : Assets.t option =
  let page : element node = medias src in
  let icon_container : element node option = page $? "div#medias-logo" in
    match icon_container with
    | None -> None
    | Some n ->
      let fst : element node = n $$ "div.gallery-item-container" |> to_list |> List.hd in
        let node : element node = (fst $ "div.gallery-item") in
        let url : string = (Soup.pretty_print node) |> get_img_url
          in Some (Assets.make LOGO (src_base_url ^ url));
;;

let db : Database.t =
  let pages_number : int = pages_count in
    make
      "HFSDB"
      games_url
      games_crawler
      pages_number
      slug_from_item
      src_from_item
      icon
      background
      logo
;;
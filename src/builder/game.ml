type t = Game of string * string * string * string * string

let title     (game : t) : string = let Game (t, _, _, _, _) = game in t
let slug      (game : t) : string = let Game (_, s, _, _, _) = game in s
let id        (game : t) : string = let Game (_, _, i, _, _) = game in i
let tmp_path  (game : t) : string = let Game (_, _, _, p, _) = game in p
let rom_path  (game : t) : string = let Game (_, _, _, _, r) = game in r

let icon_path     (game : t) : string = (tmp_path game) ^ Config.img_icon_name
let bg_path       (game : t) : string = (tmp_path game) ^ Config.img_bg_name
let startup_path  (game : t) : string = (tmp_path game) ^ Config.img_logo_name

(* Specials characters which are to avoid in ID generation. *)
let avoid_char : string = ".!:_(),-'";;

(* Checks if a word is or contains chars to avoid.
   If not, returns the first capitalized letter of the word.
   Example : "The Legend of Zelda" -> "TLOZ"
*)
let check_word (word : string) : string =
  if (int_of_string_opt word) <> None
  then word
  else
    let letter : char = Char.uppercase_ascii (word.[0]) in
      if not (String.contains_from avoid_char 0 (word.[0]))
      then String.make 1 letter
      else ""
;;

(* Create an ID of 9 characters from the slug
   Examples :
    "the-legend-of-zelda" -> "D64TLOZ"
    "super-mario-64" -> "D64SM64"
*)
let create_id (slug : string) : string =
  let words : string list = String.split_on_char '-' slug in
  let id : string = List.fold_left (fun acc word -> acc ^ (check_word word)) "" words in
  let id_length : int = String.length id in
  let id : string = if id_length > 6 then String.sub id 0 6 else id in
  let id : string = if id_length < 6 then id ^ (String.make (6 - id_length) '0') else id in
  "D64" ^ id
;;

(* Constructs a game object *)
let make (title : string) : t =
  let game_title : string = Standardizer.format_title title in
  let slug : string = Standardizer.slugify game_title in
  let id : string = create_id slug in
  let rom_path : string = Config.vita_path ^ title ^ ".n64" in
  let directory_name : string = Config.tmp_path ^ slug ^ "/" in (
    SysUtils.create_directory directory_name;
    Game (game_title, slug, id, directory_name, rom_path)
  )
;;

let download_asset (asset : Assets.t option) (path : string) : unit =
  let open Crawler in
  match asset with
  | Some a -> Lwt_main.run (download_file a.url path)
  | None -> failwith "No asset found"
;;

(* Downloads assets of a game *)
let download_assets (game : t) =
    let icon, bg, startup = Repository.find_assets (slug game)
    and media_exists : Assets.t option -> bool = fun m -> not (m = None) in (
      if media_exists icon    then (download_asset icon (icon_path game)) ;
      if media_exists bg      then (download_asset bg (bg_path game)) ;
      if media_exists startup then (download_asset startup (startup_path game)) ;
    )
;;

(* Runs conversion program which resizes images *)
let convert_assets (game : t) : unit =
  Sys.readdir (tmp_path game) |> Array.iter (fun file ->
    Assets.convert_to_png (tmp_path game ^ file)
  )
;;

(* Resizes medias *)
let resize_assets (game : t) : unit =
  Assets.resize ((icon_path game) ^ ".png") (128, 128) ;
  Assets.resize ((bg_path game) ^ ".png") (840, 500) ;
  Assets.resize ((startup_path game) ^ ".png") (280, 158)
;;

let reduce_assets (game : t) : unit =
  Assets.reduce_color_palette ((icon_path game) ^ ".png") ;
  Assets.reduce_color_palette ((bg_path game) ^ ".png") ;
  Assets.reduce_color_palette ((startup_path game) ^ ".png")
;;

let print (game : t) : unit =
  let title : string = title game
  and slug  : string = slug game in
  Printf.printf "Title: %s\tSlug:%s\n" title slug
;;

let () = SysUtils.create_directory Config.tmp_path ;;
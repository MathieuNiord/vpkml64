open Game

let is_n64 (filename : string) : bool =
  let ext : string = Filename.extension filename in
  ext = ".n64" || ext = ".z64"

let std_length : int = 20
let std_asset_length : int = 12
let standardize_output : string -> string = fun s -> Standardizer.standardize s std_length
let standardize_asset_output : string -> string = fun s -> Standardizer.standardize s std_asset_length

let game_info (game : Game.t) : string =
  let rec aux (assets : Assets.t_asset_type list) : string =
    match assets with
    | [] -> ""
    | h::t ->
      let asset : bool = Checker.check_asset h game in
      match asset with
        | true  -> (standardize_asset_output ("🟢 " ^ Assets.asset_type_to_string h)) ^ (aux t)
        | false -> (standardize_asset_output ("🔴 " ^ Assets.asset_type_to_string h)) ^ (aux t)
  in (Printf.sprintf " %s | [%s] | " (standardize_output (title game)) (standardize_output (slug game)))
  ^ (aux [Assets.ICON ; Assets.BG ; Assets.LOGO])

let print_collection (games : Game.t list) : unit =
  print_endline (Output.colorize
    (Printf.sprintf "\n[INFO]: Found %d game(s) in directory" (List.length games))
    Output.Yellow None) ;
  let sep : string = ((String.make ((std_length + 3) * 2 + 2 + (std_asset_length * 3)) '-'))
  in (
    print_endline (
      Printf.sprintf "%s\n %s | %s   |%s\n%s"
      sep
      (standardize_output "TITLE")
      (standardize_output "SLUG")
      " MEDIAS 🟢 available / 🔴 missing"
      sep
    ) ;
    List.iter (fun game -> print_endline (game_info game)) games ;
    print_endline (sep ^ "\n")
  )

let collect (roms_path : string option) : Game.t list =
  let path : string =
    match roms_path with
    | Some p -> p
    | None   -> Config.rom_folder in
      let games_list : Game.t list =
        (Sys.readdir (path)) |> Array.to_list
        |> List.filter is_n64
        |> List.map (fun rom -> Game.make (Filename.remove_extension rom))
      in (print_collection games_list ; games_list)
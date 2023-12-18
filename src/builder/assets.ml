type t_asset_type = ICON | BG | LOGO
type t = { kind : t_asset_type ; url : string }

let make (asset_type : t_asset_type) (url : string) : t = { kind = asset_type ; url = url }
let asset_ext (asset : t) : string = Filename.extension asset.url ;;

let asset_type_to_string (asset_type : t_asset_type) : string =
  match asset_type with
  | ICON -> Config.img_icon_name
  | BG -> Config.img_bg_name
  | LOGO -> Config.img_logo_name

let convert_to_png (file : string) : unit =
  if not (Filename.extension file = "png") then
    let filename : string = Filename.chop_extension file in
    let cmd : string = (Config.convert_path) ^ " " ^ (file) ^ " " ^ (filename ^ "png") in
    let _ = Sys.command cmd
    and _ = Sys.remove (file) in ()
  else ()

let resize (file : string) (size : int * int) : unit =
  let (w, h) : (int * int) = size in
  let cmd : string =
    Printf.sprintf "%s %s -strip -resize %dx%d %s"
    Config.mogrify_path file w h file
  in let _ = Sys.command cmd in ()

let reduce_color_palette (file : string) : unit =
  let cmd : string =
    Printf.sprintf "%s --force 256 %s --ext .png"
    Config.pngquant_path file
  in let _ = Sys.command cmd in ()

let to_string (asset : t) : string =
  "\n" ^ (asset_type_to_string asset.kind) ^ ": " ^ (asset.url)
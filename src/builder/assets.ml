(** 
    This module is responsible for managing the games assets used in the application. 
    @author LathErr0r
*)

type t_asset_type = ICON | BG | LOGO ;;
type t = { kind : t_asset_type ; url : string } ;;

(** [make kind url] creates a new asset of the given [kind] with the given [url]. *)
let make (asset_type : t_asset_type) (url : string) : t = { kind = asset_type ; url = url } ;;

(** [asset_ext asset] returns the file extension of the given [asset] as a string. *)
let asset_ext (asset : t) : string = Filename.extension asset.url ;;

(** [asset_type_to_string asset] returns a string representation of the given [asset]'s type. *)
let asset_type_to_string (asset_type : t_asset_type) : string =
  match asset_type with
  | ICON -> Config.img_icon_name
  | BG -> Config.img_bg_name
  | LOGO -> Config.img_logo_name
;;

(** [convert_to_png file] converts the image at the given [file] path to PNG format. *)
let convert_to_png (file : string) : unit =
  if not (Filename.extension file = "png") then
    let filename : string = Filename.chop_extension file in
    let cmd : string = (Config.convert_path) ^ " " ^ (file) ^ " " ^ (filename ^ "png") in
    let _ = Sys.command cmd
    and _ = Sys.remove (file) in ()
  else ()
;;

(** [resize_image file w h] resizes the image at the given [file] path to the specified width [w] and height [h].
    It uses the `mogrify` tool from the ImageMagick suite, the path to which is specified in the Config module. *)
let resize (file : string) (size : int * int) : unit =
  let (w, h) : (int * int) = size in
  let cmd : string = Printf.sprintf "%s %s -strip -resize %dx%d %s" Config.mogrify_path file w h file
  in let _ = Sys.command cmd in ()
;;

(** [reduce_color_palette file] reduces the color palette of the image at the given [file] path to 256 colors.
    It uses the `pngquant` tool, the path to which is specified in the Config module. *)
let reduce_color_palette (file : string) : unit =
  let cmd : string = Printf.sprintf "%s --force 256 %s --ext .png" Config.pngquant_path file
  in let _ = Sys.command cmd in ()
;;

(** [to_string asset] converts the given [asset] to a string representation.
    The resulting string includes the type of the asset and its URL. *)
let to_string (asset : t) : string =
  "\n" ^ (asset_type_to_string asset.kind) ^ ": " ^ (asset.url)
;;
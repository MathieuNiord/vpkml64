open Yojson.Basic.Util
open Assets
open Wrapper

type t = Yojson.Basic.t ;;

(* Returns a json object from parsing a json file. *)
let parse_file : string -> t = Yojson.Basic.from_file ;;

let count_entries json =
  match json with
  | `Assoc entries -> List.length entries
  | _ -> failwith "JSON is not an object"
;;

(* Creates a new file and adds its content. *)
let write (content : t) (file : string) : unit =
  if content = `Null then ()
  else
    let oc = open_out file in
    Printf.fprintf oc "%s" (content |> Yojson.Basic.pretty_to_string);
    close_out oc
;;

(* Gets the source of an asset from a json
   None if the asset doesn't exist *)
let to_asset_option (json : t) : string option =
  match json with
  | `Null -> None
  | _ -> to_string_option json
;;

module Serializer = struct

  (* Converts a Assets.t object into a json object for file writing *)
  let from_asset (asset : Assets.t option) : string * t =
    match asset with
    | None -> "", `Null
    | Some a -> (a.kind |> asset_type_to_string), `String (a.url)
  ;;

  (* Converts a Wrapper.t object into a json object for file writing *)
  let from_data (record : Wrapper.t) : string * t =
    record.title, `Assoc [
      ("src", `String record.src);
      ("assets", `Assoc (
        let rec aux (assets : Assets.t option list) : (string * t) list =
          match assets with
          | [] -> []
          | hd::tl -> if hd <> None then (from_asset hd)::(aux tl) else (aux tl)
        in aux [record.icon; record.bg; record.logo])
    )]
  ;;

  (* Converts a Wrapper.t list into a json object for file writing *)
  let from_list (records : Wrapper.t list) : t =
    `Assoc (List.map (fun (d) -> from_data d) records)
  ;;

end

module Deserializer = struct

  let to_asset_opt (asset : t_asset_type) (json : t) : Assets.t option =
    match json with
    | `String url -> Some {kind = asset ; url = url}
    | _ -> None
  ;;

  let to_data (json : string * t) : Wrapper.t =
    let title, content = json in
    match content with
    | `Null -> failwith "Can't convert null object into a data object."
    | c ->
      let src : string = c |> member "src" |> Yojson.Basic.Util.to_string
      and assets : t = c |> member "assets" in
        let icon  : Assets.t option = assets |> member Config.img_icon_name |> to_asset_opt ICON
        and bg    : Assets.t option = assets |> member Config.img_bg_name   |> to_asset_opt BG
        and logo  : Assets.t option = assets |> member Config.img_logo_name |> to_asset_opt LOGO in
          { title ; src ; icon ; bg ; logo }
  ;;

  let to_list (json : t) : Wrapper.t list =
    match json with
    | `Assoc entries ->
      let rec aux (entries : (string * t) list) : Wrapper.t list =
        match entries with
        | [] -> []
        | hd::tl -> (to_data hd)::(aux tl)
      in aux entries
    | _ -> failwith "Can't convert json object into a list."
  ;;

end

(* Prints a json object on console output (Debugging). *)
let pretty_print (json : t) : unit = print_endline (Yojson.Basic.pretty_to_string json) ;;
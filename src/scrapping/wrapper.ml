type t = {
  title : string;
  src   : string;
  icon  : Assets.t option;
  bg    : Assets.t option;
  logo  : Assets.t option;
}

let make (slug : string) (page_url : string) (db : Database.t) : t =
  { title = slug
  ; src = page_url
  ; icon = (Database.icon page_url db)
  ; bg = (Database.background page_url db)
  ; logo = (Database.logo page_url db) }

let empty : t = { title = "" ; src = "" ; icon = None ; bg = None ; logo = None }

let asset (a : Assets.t_asset_type) (wrapper : t) : Assets.t option =
  let open Assets in
  match a with
  | ICON -> wrapper.icon
  | BG -> wrapper.bg
  | LOGO -> wrapper.logo

let check (a : Assets.t_asset_type) (wrapper : t) : bool =
  match (asset a wrapper) with
  | None -> false
  | Some _ -> true

let set_asset (asset : Assets.t_asset_type) (wrapper : t) (db : Database.t) : t =
  let open Assets in
  match asset with
  | ICON  -> { wrapper with icon = (Database.icon wrapper.src db) }
  | BG    -> { wrapper with bg = (Database.background wrapper.src db) }
  | LOGO  -> { wrapper with logo = (Database.logo wrapper.src db) }

let update (db : Database.t) (wrapper : t) : t =
  let rec aux (assets : Assets.t_asset_type list) : t =
    match assets with
    | [] -> wrapper
    | hd::t ->
      if not (check hd wrapper) then
        set_asset hd (aux t) db
      else aux t
  in aux [ICON; BG; LOGO]

let merge (from : t) (into : t) : t =
  let merge_asset (a : Assets.t_asset_type) : Assets.t option =
    match (asset a into) with
    | None -> (asset a from)
    | Some asset_into -> Some asset_into
  in
  { title = into.title
  ; src = into.src
  ; icon = merge_asset ICON
  ; bg = merge_asset BG
  ; logo = merge_asset LOGO }

let ( => ) : t -> t -> t = fun from into -> merge from into

let sync (wrapper : t) (db : Database.t) (src : string) : t =
  let check (kind : Assets.t_asset_type) : bool =
    match (asset kind wrapper)  with
    | None -> false
    | _ -> true
  in
    let w_icon : t = 
      if not (check ICON) then { wrapper with icon = (Database.icon src db) }
      else wrapper in
    let w_bg : t =
      if not (check BG) then { w_icon with bg = (Database.background src db) }
      else w_icon in
    let w_logo : t =
      if not (check LOGO) then { w_bg with logo = (Database.logo src db) }
      else w_bg
    in w_logo

let to_string_asset (asset : Assets.t option) : string =
  match asset with
  | None -> ""
  | Some a -> Assets.to_string a

let to_string (data : t) : string =
  Printf.sprintf "SLUG: %s\nSRC: %s%s%s%s\n\n"
    data.title data.src
    (to_string_asset data.icon)
    (to_string_asset data.bg)
    (to_string_asset data.logo)
(** The Repository module provides functions for interacting with a database of records. *)

open Json

(** [local_databases] is a list of all local databases. *)
let local_databases : Database.t list = [DbHfsdb.db ; DbGamesdb.db]

(** [count db] returns the number of records in the database [db]. *)
let count (db : Database.t) : int =
  let json : Json.t = Json.parse_file db.file in
  Json.Deserializer.to_list json |> List.length

(** [get slug db] returns the record with the given [slug] from the database [db],
    or [None] if no such record exists. *)
let get (slug : string) (db : Database.t) : Wrapper.t option =
  if not (Sys.file_exists db.file) then None
  else
    let open Yojson.Basic.Util in
    let json : Json.t = Json.parse_file db.file in
    match json |> member slug with
    | `Null -> None
    | obj -> Some ((slug, obj) |> Deserializer.to_data)

(** [get_records db] returns a list of all records in the database [db]. *)
let get_records (db : Database.t) : Wrapper.t list =
  if not (Sys.file_exists db.file) then []
  else
    let json : Json.t = Json.parse_file db.file in
    Json.Deserializer.to_list json

(** [find slug] returns the record with the given [slug] from the local databases,
    or [None] if no such record exists. *)
let find (slug : string) : Wrapper.t option =
  let rec aux (databases : Database.t list) : Wrapper.t option =
    match databases with
    | [] -> None
    | hd::tl ->
      match (get slug hd) with
      | None -> aux tl
      | Some record -> Some record
  in aux local_databases

(** [find_asset slug asset] returns the asset of type [asset] from the record
    with the given [slug] in the local databases, or [None] if no such record
    or asset exists. *)
let find_asset (slug : string) (asset : Assets.t_asset_type) : Assets.t option =
  let rec aux (databases : Database.t list) : Assets.t option =
    match databases with
    | [] -> None
    | hd::tl ->
      let record : Wrapper.t option = get slug hd in
        match record with
        | None -> aux tl
        | Some r ->
          match (r |> Wrapper.asset asset) with
          | None -> aux tl
          | Some a -> Some a
  in aux local_databases

(** [find_assets slug] returns the ICON, BG, and LOGO assets from the record
    with the given [slug] in the local databases. Each asset is returned as an option,
    which is [None] if the asset does not exist. *)
let find_assets (slug : string) : Assets.t option * Assets.t option * Assets.t option =
  (find_asset slug ICON), (find_asset slug BG), (find_asset slug LOGO)

(** [add db record] adds the [record] to the database [db]. *)
let add (db : Database.t) (record : Wrapper.t) : unit =
  let current_records : Wrapper.t list = get_records db in
  let records : Wrapper.t list = record::current_records in
  let json : Json.t = Json.Serializer.from_list records in
  Json.write json db.file

(** [add_records db records] adds the list of [records] to the database [db]. *)
let add_records (db : Database.t) (records : Wrapper.t list) : unit =
  if records = [] then ()
  else
    let current_records : Wrapper.t list = get_records db in
    let records : Wrapper.t list = records @ current_records in
    let json : Json.t = Json.Serializer.from_list records in
    Json.write json db.file

let overwrite (db : Database.t) (records : Wrapper.t list) : unit =
  let json : Json.t = Json.Serializer.from_list records in
  Json.write json db.file

let update (slug : string) : unit =
  let open Wrapper in
  let rec aux (databases : Database.t list) : unit =
    match databases with
    | [] -> ()
    | hd::tl ->
      let record : Wrapper.t option = get slug hd in
        match record with
        | None -> aux tl
        | Some _ ->
          let updated_list : Json.t =
            (get_records hd) |> List.map (fun r ->
              if (String.equal r.title slug) then (Wrapper.update hd r)
              else r
            ) |> Json.Serializer.from_list
          in Json.write updated_list hd.file
  in aux local_databases

let update_records (records : Wrapper.t list) : unit =
  let rec aux (databases : Database.t list) : unit =
    match databases with
    | [] -> ()
    | hd::tl ->
      let updated_list : Json.t =
        (get_records hd) |> List.map (fun r ->
          if (List.mem r records) then (Wrapper.update hd r)
          else r
        ) |> Json.Serializer.from_list
      in Json.write updated_list hd.file ;
      aux tl
  in aux local_databases

let update_database (db : Database.t) : unit =
  let games : Wrapper.t list = get_records db in
  let bar : Progress.t = Progress.create (List.length games) in
  let updated_list : Json.t =
    games |> List.map (fun r ->
      let updated : Wrapper.t = Wrapper.update db r in
      Progress.increment bar ;
      Progress.print bar (Some r.title);
      updated
    ) |> Json.Serializer.from_list
  in Json.write updated_list db.file

let init : unit = SysUtils.create_directory Config.db_path
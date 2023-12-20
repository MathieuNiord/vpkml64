open Soup
open Crawler

let games_list (db : Database.t) (page : int) (pb : Progress.t) : Wrapper.t list =
  let soup = Database.soup db page in
  let items = browse_elements db.games_list_crawler soup |> to_list in
  List.map (fun item ->
    let title   : string = db.slug_from_item item
    and source  : string = db.src_from_item item in
    Progress.increment pb;
    Progress.print pb (Some title);
    Wrapper.make title source db
  ) items

let recently_added (db : Database.t) : int =
  let count : int = Repository.count db in
  let new_count : int = Database.games_number db in
  new_count - count

let recent_games_list (db : Database.t) : Wrapper.t list =
  let added : int = recently_added db in
  if added = 0 then (
    print_string (Output.colorize
      (Printf.sprintf "\n[INFO]: No new games found on %s" db.name)
      Output.Yellow Output.None
    ) ; flush stdout ; []
  )
  else (
    print_endline (Output.colorize
      (Printf.sprintf "\n[INFO]: %d new game(s) found on %s" added db.name)
      Output.Yellow Output.None
    ) ;
    let pages : int = db.pages_count in
      List.concat_map (fun page ->
        let soup = Database.soup db page in
        let items = browse_elements db.games_list_crawler soup |> to_list in
        let bar = Progress.create (List.length items) in
          List.fold_left (fun acc item ->
            let title   : string = db.slug_from_item item
            and source  : string = db.src_from_item item in (
              Progress.increment bar ;
              Progress.print bar (Some title) ;
              match (Repository.get title db) with
              | None -> (Wrapper.make title source db)::acc
              | _ -> acc
          )) [] items
      ) (List.init pages ((+) 1)))

let scrap_database (db : Database.t) : Wrapper.t list =
  let pages : int = db.pages_count
  and games_count : int = Database.games_number db in
  print_string (
    Output.colorize
      (Printf.sprintf "\n[INFO]: Found %d games on %s\n" games_count db.name)
      Output.Yellow
      Output.None
  );
  let bar = Progress.create games_count in
  List.concat_map (fun page -> games_list db page bar) (List.init pages ((+) 1))

let scrap (db : Database.t) : unit =
  scrap_database db |> Repository.overwrite db

let scrap_recents (db : Database.t) : unit =
  recent_games_list db |> Repository.add_records db
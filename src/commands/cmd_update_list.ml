open Cmd

let header () : string =
  let open Output in
  (build_title ())
  ^ (build_light_title "Updating databases games list")
  ^ "\n"
  ^ (centered ("Steps details:                                                     \n"))
  ^ (centered ("-------------------------------------------------------------------\n"))
  ^ (centered ("1. Compares entries of current databases with actual online entries\n"))
  ^ (centered ("2. Retrieves new entries and build a list of new games data        \n"))
  ^ (centered ("3. Appends new data to local databases                             \n"))
  ^ "\n"
  ^ (colorize (centered "[INFO]: It could take a moment, please wait patiently till the end of the update <3.") Yellow None)
  ^ "\n\n"

let update () : unit =
  Display.print_output (header ()) ;
  List.iter (fun db -> Scrapper.scrap_recents db ) Repository.local_databases ;
  Menu.back_to_menu ()

let initial_state : t_state =
  let files_count : int = Sys.readdir Config.db_path |> Array.length in
  if (files_count < (Repository.local_databases |> List.length)) then DISABLED else ENABLED

let cmd : t = { name = "Update games list" ; f = update ; state = ref initial_state }
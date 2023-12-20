open Cmd

let header (i : int) : string =
  let open Output in
  (build_title ())
  ^ (build_light_title "Updating databases medias")
  ^ "\n"
  ^ (centered ("Steps details:                                                       \n"))
  ^ (centered ("---------------------------------------------------------------------\n"))
  ^ (centered ("1. Connects to the database and retrieve the list of games           \n"))
  ^ (centered ("2. For each game, checks missing medias and attempts to retrieve them\n"))
  ^ (centered ("3. Updates local databses                                            \n"))
  ^ "\n"
  ^ (colorize (centered "[INFO]: It could take a moment, please wait patiently till the end of the update <3.") Yellow None)
  ^ "\n\n"
  ^ ("Database [" ^ (string_of_int i) ^ "/" ^ (string_of_int (List.length Repository.local_databases)) ^ "]\n")

let update () : unit =
  List.iteri (fun i db ->
      Display.print_output (header (i + 1)) ;
      Repository.update_database db ;
  ) Repository.local_databases ;
  Menu.back_to_menu ()

let initial_state : t_state =
  let files_count : int = Sys.readdir Config.db_path |> Array.length in
  if (files_count < (Repository.local_databases |> List.length)) then DISABLED else ENABLED

let cmd : t = { name = "Update games medias" ; f = update ; state = ref initial_state }
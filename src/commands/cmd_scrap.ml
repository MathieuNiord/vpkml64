open Cmd

let header (i : int) : string =
  let open Output in
  (build_title ())
  ^ (build_light_title "Scrapping games")
  ^ "\n"
  ^ (centered ("Steps details:                                                  \n"))
  ^ (centered ("----------------------------------------------------------------\n"))
  ^ (centered ("1. Connects to the database and retrieve the list of games      \n"))
  ^ (centered ("2. For each game, gets medias and their sources                 \n"))
  ^ (centered ("3. Writes the final result in a local file which becomes your db\n"))
  ^ "\n"
  ^ (colorize (centered "[INFO]: It should take a moment, please wait patiently till the end of the update <3.") Yellow None)
  ^ "\n\n"
  ^ ("Database [" ^ (string_of_int i) ^ "/" ^ (string_of_int (List.length Repository.local_databases)) ^ "]\n")

let update () : unit =
  List.iteri (fun i db ->
      Display.print_output (header (i + 1)) ;
      Scrapper.scrap db ;
  ) Repository.local_databases ;
  if (!((Cmd_build.cmd).state) = DISABLED) then set_state Cmd_build.cmd ENABLED ;
  if (!((Cmd_update_list.cmd).state) = DISABLED) then set_state Cmd_update_list.cmd ENABLED ;
  if (!((Cmd_update_medias.cmd).state) = DISABLED) then set_state Cmd_update_medias.cmd ENABLED ;
  Menu.back_to_menu ()

let initial_state : t_state =
  let files_count : int = Sys.readdir Config.db_path |> Array.length in
  if (files_count < (Repository.local_databases |> List.length)) then IMPORTANT else ENABLED

let cmd : t = { name = "Scrap databases" ; f = update ; state = ref initial_state }
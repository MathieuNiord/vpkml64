let databases : Database.t list = [DbHfsdb.db; DbGamesdb.db] ;;

let header (i : int) : string =
  let open Output in
  (build_title ())
  ^ (build_light_title "Updating databases medias")
  ^ "\n"
  ^ (colorize (centered "[INFO]: It should take a moment, please wait patiently till the end of the update <3.") Yellow None)
  ^ "\n\n"
  ^ (centered ("Steps details:                                                  \n"))
  ^ (centered ("----------------------------------------------------------------\n"))
  ^ (centered ("1. Connects to the database and retrieve the list of games      \n"))
  ^ (centered ("2. For each game, gets medias and their sources                 \n"))
  ^ (centered ("3. Writes the final result in a local file which becomes your db\n"))
  ^ "\n"
  ^ ("Database [" ^ (string_of_int i) ^ "/" ^ (string_of_int (List.length databases)) ^ "]\n")
;;

let update () : unit =
  List.iteri (fun i db ->
      Display.print_output (header (i + 1)) ;
      Repository.update_database db ;
  ) databases ;
  Menu.back_to_menu ()
;;

let cmd : Cmd.t = ("Update games medias", update) ;;
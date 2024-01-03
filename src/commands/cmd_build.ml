open Cmd

let build () : unit =
  let open Game in
  let open Output in
    Display.print_output ((Output.build_title ()) ^ (Output.build_light_title "Build .vpk from .n64")) ;
    let complete_games : Game.t list = Collector.collect (None) |> Checker.check_all in (
      if (List.length complete_games) = 0 then SysUtils.create_directory Config.vpks_path ;
      complete_games
      |> List.iter (fun game ->
        ( print_endline (colorize (Printf.sprintf "Building %s" (Game.title game)) Green None)
        ; Display.print_action "Directory creation"       (fun () -> SysUtils.create_directory Config.vpks_path)
        ; Display.print_action "Assets recovering"        (fun () -> download_assets game)
        ; Display.print_action "Assets conversion"        (fun () -> convert_assets game)
        ; Display.print_action "Assets resizing"          (fun () -> resize_assets game)
        ; Display.print_action "Color palette reduction"  (fun () -> reduce_assets game)
        ; Display.print_action "Vita package building"    (fun () -> Builder.build game)
        ; Builder.clean game
        ; print_endline "\n"
      ))
      ; Menu.back_to_menu ()
    )

let initial_state : t_state =
  if ((Repository.count_all ()) = 0) then DISABLED else ENABLED

let cmd : t = { name = "Build .vpk from .n64" ; f = build ; state = ref initial_state }
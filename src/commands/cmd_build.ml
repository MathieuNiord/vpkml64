let build () : unit =
  let open Game in
  let open Output in
    Display.print_output ((Output.build_title ()) ^ (Output.build_light_title "Build .vpk from .n64")) ;
    Collector.collect (None)
    |> Checker.check_all
    |> List.iter (fun game ->
      ( print_endline (colorize (Printf.sprintf "Building %s" (Game.title game)) Green None)
      ; Display.print_action "Directory creation"     (fun () -> SysUtils.create_directory Config.vpks_path)
      ; Display.print_action "Assets recovering"      (fun () -> download_assets game)
      ; Display.print_action "Assets conversion"      (fun () -> convert_assets game)
      ; Display.print_action "Assets resizing"        (fun () -> resize_assets game)
      ; Display.print_action "Color palet reduction"  (fun () -> reduce_assets game)
      ; Display.print_action "Vita package building"  (fun () -> Builder.build game)
      ; Builder.clean game
      ; print_endline "\n"
    ))
    ; Menu.back_to_menu ()
;;

let cmd : Cmd.t = ("Build .vpk from .n64", build) ;;
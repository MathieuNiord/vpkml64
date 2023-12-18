open Output

let show_credits () : unit =
  let credits = open_in Config.credits_path in
  let rec read_credits () : string =
    try
      let line = input_line credits in
      (centered line) ^ "\n" ^ read_credits ()
    with End_of_file -> close_in credits ; ""
  in
  Display.print_output ((build_title ()) ^ (read_credits ())) ;
  Menu.back_to_menu ()
;;

let cmd : Cmd.t = ("Show credits", show_credits) ;;
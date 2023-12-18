type t = Display of string | None
type t_action = Clear | Clear_line | Flush

let hide_cursor () : unit = print_string "\027[?25l"

let make_action (action : t_action) : unit =
  match action with
  | Clear -> print_string "\027[2J\027[1;1H"
  | Clear_line -> print_string "\027[2K"
  | _ -> ()
  ; flush stdout

let columns : int ref = ref !Terminal_width.latest_width

let compute_width (output : string) : int =
  String.split_on_char '\n' output
  |> List.map String.length
  |> List.fold_left max 0

let print_output (output : string) : unit =
  make_action Clear ;
  print_string ("\r" ^ output) ;
  hide_cursor () ;
  make_action Flush

let print_action (info : string) f : unit =
  print_string ("\r" ^ info) ;
  make_action Flush ;
  f () ;
  Unix.sleepf 0.2 ;
  print_string ("\r✅ Done - " ^ info ^ "\n") ;
  make_action Flush
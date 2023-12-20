
(* Enum class of terminal colors *)
type color = Black | Red | Green | Yellow | Blue | Magenta | Cyan | White | Grey | None

let title   : string = SysUtils.read_file Config.title_path
let credits : string = SysUtils.read_file Config.credits_path
let flag_colors : color list = [Red; Yellow; Green; Cyan; Blue; Magenta]

(* Parses color and returns terminal output code *)
let code_of_color (c : color) (is_background : bool) : string =
  let base_code = if is_background then 40 else 30 in
  match c with
  | Black   -> string_of_int (base_code)
  | Red     -> string_of_int (base_code + 1)
  | Green   -> string_of_int (base_code + 2)
  | Yellow  -> string_of_int (base_code + 3)
  | Blue    -> string_of_int (base_code + 4)
  | Magenta -> string_of_int (base_code + 5)
  | Cyan    -> string_of_int (base_code + 6)
  | White   -> string_of_int (base_code + 7)
  | Grey    -> string_of_int (base_code + 60)
  | None    -> if is_background then "40" else "37"

(* Colorize text with a color and background color *)
let colorize (text : string) (c : color) (bg : color) : string =
  let c   : string = code_of_color c false in
  let bg  : string = code_of_color bg true in
  ("\027[" ^ c ^ ";" ^ bg ^ "m" ^ text ^ "\027[0m")

(* Centers text on the terminal output *)
let centered (text : string) : string =
  let width       : int     = Terminal_width.get ()
  and text_length : int     = String.length text in
  let spaces      : string  = String.make ((width - text_length) / 2) ' '
  in (spaces ^ text)

(* Get the maximum characters from lines based in the fixed number on columns
   Example:
      max_line_len ["first"; "second"; "third"] 2 (3 options for 2 columns)
      1 -> "fisrt".len + "second".len = 11
      2 -> "third".len = 5
      3 -> res = 11
   Goal: Knowing a static max width for options display *)
let max_line_len (options : string list) (columns : int) : int =
  let rec aux (options : string list) (max : int) (acc : int) (i : int) : int =
    match options with
    | [] -> if acc > max then acc else max
    | h::t ->
      let len : int = String.length h in
      let new_acc : int = acc + len in
      if ((i + 1) mod columns = 0) then
        let new_max : int =
          if new_acc > max then new_acc else max
        in aux t new_max 0 (i + 1)
      else aux t max (acc + len) (i + 1)
  in aux options 0 0 0

(* Defines the max word length *)
let max_word_len (options : string list) : int =
  options |> List.map String.length |> List.fold_left max 0

let option_output (cmd : Cmd.t) (number : int) (selected : bool) : string =
  let open Cmd in
  let fg_color : color = if selected then Black else
    match !(cmd.state) with
    | IMPORTANT -> Green
    | ENABLED  -> White
    | DISABLED -> Grey
  and bg_color : color =
    if selected then
      match !(cmd.state) with
      | IMPORTANT -> Green
      | DISABLED -> Grey
      | _ -> White
    else None
  in (colorize (string_of_int number ^ ". " ^ cmd.name) fg_color bg_color)

(* Display a list of options on two columns from a list as:
   ["first"; "second"; "third"] -> "1. first\t\t2. second\n3. third\n"
   The choice parameter defines the options that's going to be highlighted *)
let build_options (options : Cmd.t list) (choice : int) : string * int =
  let open Cmd in
  let width : int = Terminal_width.get ()
  and names : string list = List.map (fun c -> c.name) options in
  let max_word_len : int = (max_word_len names) in
  let (max_chars, cols) : (int * int) =
    let max = max_line_len names 2
    and min = max_line_len names 1 in
      if (max + 10) < width then (max + 10), 2  (* 10 equals 3*2 ("1. ", "2. ") + 4 spaces between columns *)
      else (min + 3), 1
  in
  let begin_spaces : string = String.make ((width - max_chars) / 2) ' ' in (
    let rec aux (options : Cmd.t list) (choice : int) (i : int) (lst_wrd_len : int) : string =
      match options with
      | [] -> ""
      | h :: t ->
        let prefix =
          if i = 1 then ("\n" ^ begin_spaces)
          else if cols = 1 then ("\n\n" ^ begin_spaces)
          else
            let spaces = String.make (max_word_len - lst_wrd_len + 4) ' ' in
            if i mod cols = 0 then spaces
            else ("\n\n" ^ begin_spaces)
        in
        let option_str = option_output h i (i = choice) in
          prefix ^ option_str ^ (aux t choice (i + 1) (String.length h.name))
    in ((aux options choice 1 0) ^ "\n\n"), cols
  )

(*
  Displays a title on the terminal output as:
            ======================
            |       TITLE        |
            ======================
*)
let build_light_title (title : string) : string =
  let title_length = String.length title in
  let line = String.make (title_length + 10) '=' in
  "\n" ^ (centered line) ^ "\n"
  ^ (centered ("|    " ^ title ^ "    |")) ^ "\n"
  ^ (centered line) ^ "\n"

(* Returns true if there's any space to contain the title in prompt *)
let necessary_width () : bool = (Terminal_width.get ()) |> (<) (title |> Display.compute_width)

(* Displays title with pride flag colors
   Each line is print in one color of the pride flag *)
let build_title () : string =
  if (necessary_width ()) then
    String.split_on_char '\n' title
    |> List.mapi (fun i line ->
      let color : color = List.nth flag_colors (i mod (List.length flag_colors)) in
      (colorize (centered line) color None))
    |> String.concat "\n"
  else centered "Welcome to VpkMl64!" ^ "\n\n"
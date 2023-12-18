
(* Enum class of terminal colors *)
type color = Black | Red | Green | Yellow | Blue | Magenta | Cyan | White | None

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
  | None    -> if is_background then "40" else "37"

(* Colorize text with a color and background color *)
let colorize (text : string) (c : color) (bg : color) : string =
  let c = code_of_color c false in
  let bg = code_of_color bg true in
  ("\027[" ^ c ^ ";" ^ bg ^ "m" ^ text ^ "\027[0m")

(* Centers text on the terminal output *)
let centered (text : string) : string =
  let width : int = Terminal_width.get () in
  let text_length = String.length text in
  let spaces = String.make ((width - text_length) / 2) ' ' in
  (spaces ^ text)

(* Get the maximum characters from lines based in the fixed number on columns
   Example:
      max_line_len ["first"; "second"; "third"] 2 (3 options for 2 columns)
      1 -> "fisrt".len + "second".len = 11
      2 -> "third".len = 5
      3 -> res = 11
   Goal: Knowing a static max width for options display
*)
let max_line_len (options : string list) (columns : int) : int =
  let rec aux (options : string list) (max : int) (acc : int) (i : int) : int =
    match options with
    | [] -> if acc > max then acc else max
    | h::t ->
      let len : int = String.length h in
      let new_acc : int = acc + len in
      if ((i + 1) mod columns = 0) then
        let new_max : int = if new_acc > max then new_acc else max in
        aux t new_max 0 (i + 1)
      else
        aux t max (acc + len) (i + 1)
  in aux options 0 0 0

(* Defines the max word length *)
let max_word_len (options : string list) : int =
  let rec aux (options : string list) (max : int) : int =
    match options with
    | [] -> max
    | h::t -> let len : int = String.length h in
      if len > max then aux t len
      else aux t max
  in aux options 0

(* Display a list of options on two columns from a list as:
   ["first"; "second"; "third"] -> "1. first\t\t2. second\n3. third\n"
   The choice parameter defines the options that's going to be highlighted
*)
let build_options (options : string list) (choice : int) : string * int =
  let width : int = !Display.columns             (* Width of the console *)
  and max_word_len : int = (max_word_len options) in  (* Max length of a word + 4 spaces *)
  let (max_chars, cols) : (int * int) =               (* Max length of a line *)
    let max = max_line_len options 2
    and min = max_line_len options 1 in
      if (max + 10) < width then (max + 10), 2        (* 10 equals 3*2 ("1. ", "2. ") + 4 spaces between columns *)
      else (min + 3), 1
  in
  let begin_spaces : string = String.make ((width - max_chars) / 2) ' ' in (
    let rec aux (options : string list) (choice : int) (i : int) (lst_wrd_len : int) : string =
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
        let option_str =
          let opt : string = string_of_int i ^ ". " ^ h in
          if i = choice then (colorize opt Black White)
          else opt
        in prefix ^ option_str ^ (aux t choice (i + 1) (String.length h))
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
  (centered (line ^ "\n"))
  ^ (centered ("|    " ^ title ^ "    |\n"))
  ^ (centered (line ^ "\n"))

(* Returns true if there's any space to contain the title in prompt *)
let necessary_width () : bool =
  let width = !Display.columns in
  let title = open_in Config.title_path in
    let enough : bool =
      try let line = input_line title in String.length line < width
      with End_of_file -> true
    in (
      close_in title;
      enough
    )

let flag_colors : color list = [Red; Yellow; Green; Cyan; Blue; Magenta]

(* Displays title with pride flag colors
   Each line is print in one color of the pride flag
   Colors list is [None; None; Red; Yellow; Green; Cyan; Blue; Magenta; Red; Yellow; Green; None; None;]
*)
let build_title () : string =
  if (necessary_width ()) then (
    let title = open_in Config.title_path in
    let rec write_title (colors : color list) acc =
      match colors with
      | [] -> failwith "Error: flag_colors list is empty"
      | h :: t ->
          try
            let line = input_line title in
            let colored_line = colorize (centered (line ^ "\n")) h None in
            write_title (t @ [h]) (acc ^ colored_line)
          with End_of_file -> acc
    in 
    let result = write_title flag_colors "" in
    close_in title;
    result
  )
  else centered "Welcome to VpkMl64!" ^ "\n\n"
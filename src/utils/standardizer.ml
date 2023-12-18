(*  Removes (), [] or {} ant their contents in titles 
    Examples:
      "The Legend of Zelda (Eur) [U]" -> "The Legend of Zelda"
      "Super Mario 64 [U] {Z}" -> "Super Mario 64"   
*)
let format_title (title : string) : string =
  let open Str in
  (* Since regex can't retrieve parenthesis (group syntax = "\(\)"),
     changes parenthesis and brackets into curly brackets ("{}") *)
  let new_title = String.map (
    fun c ->
      match c with
      | '(' | '[' -> '{'
      | ')' | ']' -> '}'
      | _ -> c
   ) title in
    let reg = regexp {| {[A-Za-z0-9!, ]+}|} in global_replace reg "" new_title
;;

(* Transforms titles into slugs
   Examples:
    "The Legend of Zelda - Ocarina of Time" -> "the-legend-of-zelda-ocarina-of-time"
    "Super Mario 64" -> "super-mario-64"
    "The Legend of Zelda: Majora's Mask" -> "the-legend-of-zelda-majoras-mask"
*)
let slugify str =
  let open Str in
  let reg = regexp "[^a-zA-Z0-9]+" in
  let res : string = global_replace reg "-" str in
  let res = String.lowercase_ascii res in
  let res = Str.replace_first (Str.regexp "^-") "" res in
  let res = Str.replace_first (Str.regexp "-$") "" res in
  res
;;

(* Standardizes for printing on a maw length *)
let standardize (text : string) (max_length : int) : string =
  let length = String.length text in
  if length > max_length then
    (String.sub text 0 (max_length - 3)) ^ "..."
  else
    let remaining = max_length - length in
      text ^ String.make remaining ' '
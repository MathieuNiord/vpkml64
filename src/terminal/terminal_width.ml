type dimensions = { rows : int; columns : int }

external get_dimensions : unit -> dimensions option = "ocaml_terminal_get_terminal_dimensions"

let get_columns () : int =
  match get_dimensions () with
  | Some { columns; _ } -> columns
  | None -> 0

let latest_width : int ref = ref (get_columns ())

let get () : int = !latest_width
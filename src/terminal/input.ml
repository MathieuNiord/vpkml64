(** The Input module provides functions for handling user input. *)

(** The [t] type represents different kinds of user input. *)
type t = UP | DOWN | LEFT | RIGHT | ENTER | QUIT | None ;;

(** [process input nb_choices choice cols] processes the user input and returns the new choice.
    [input] is the user input.
    [nb_choices] is the number of choices available.
    [choice] is the current choice.
    [cols] is the number of columns in the choice layout. *)
let process (input : t) (nb_choices : int) (choice : int) (cols : int) : int =
  let user_input : int =
    match input with
    | UP -> -cols
    | DOWN -> cols
    | LEFT -> -1
    | RIGHT -> 1
    | _ -> 0
  in
    let new_choice : int = choice + user_input in
      if (new_choice < 1) || (new_choice > nb_choices) then choice
      else new_choice
;;

(** [read_input ()] reads the user input and returns it as a value of type [t].
    This function is implemented in C and registered with OCaml using the [Callback.register] function. *)
external read_input : unit -> t = "ocaml_input_get_interaction" ;;

(** [get ()] reads the user input and returns it as a value of type [t].
    If the user input is [None], it calls itself recursively until a valid input is read. *)
let rec get () : t =
  let input : t = read_input () in
    match input with
    | None -> get ()
    | _ -> input

(** Register the C functions with OCaml. *)
let () = 
  Callback.register "Up" (fun () -> UP)
  ; Callback.register "Down" (fun () -> DOWN)
  ; Callback.register "Left" (fun () -> LEFT)
  ; Callback.register "Right" (fun () -> RIGHT)
  ; Callback.register "Enter" (fun () -> ENTER)
  ; Callback.register "Exit" (fun () -> QUIT)
  ; Callback.register "None" (fun () -> None)
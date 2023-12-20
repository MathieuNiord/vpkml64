(* 
  This module provides a way to create and display a menu in the console. 
  It allows the user to navigate through the menu options using arrow keys and select an option by pressing Enter.
*)

open Output

module type Private =
sig
  type t = string * Cmd.t list
  val lst_menu : t ref
  val set_menu : t -> unit
  val get_menu : unit -> t
  val get_menu_title : t -> string    (* Returns the title of the menu *)
  val get_commands : t -> Cmd.t list  (* Returns the list of options in the menu *)
  val get_command : t -> int -> Cmd.t (* Returns the option at the given index in the menu *)
  val get_commands_length : t -> int  (* Returns the number of options in the menu *)
  val run_command : t -> int -> unit  (* Runs the function associated with the option at the given index in the menu *)
end

module Private : Private =
struct
  type t = string * Cmd.t list ;;
  let lst_menu : t ref = ref ("", []) ;;

  let set_menu (menu : t) : unit = lst_menu := menu
  let get_menu () : t = !lst_menu

  let get_menu_title (m : t) : string = let (title, _) = m in title
  let get_commands (m : t) : Cmd.t list =  let (_, commands) = m in commands

  let get_command (m : t) (i : int) : Cmd.t =
    let commands = get_commands m in
    List.nth commands (i - 1)

  let get_commands_length (m : t) : int =
    let commands = get_commands m in
    List.length commands

  let run_command (menu : t) (selected : int) : unit =
    let open Cmd in
    Display.make_action Clear ;
    let commands = get_commands menu in
    let cmd = List.nth commands (selected - 1) in
      if !(cmd.state) = IMPORTANT then set_state cmd ENABLED ;
      run cmd
end

type t = Private.t

(* Creates a new menu with the given title and options *)
let create (title : string) (options : Cmd.t list) : t = (title, options)

(* Displays the menu and handles user input *)
let show (menu : t) : unit =
  let open Private in
  set_menu menu;
  let title : string = get_menu_title menu
  and options : Cmd.t list = get_commands menu in
  let rec aux (choice : int) : unit =
    let display, cols = build_options (get_commands menu) choice in (
      Display.print_output ((Output.build_title ()) ^ (Output.build_light_title title) ^ display);
      let input : Input.t = Input.get () in (
        let new_choice : int = Input.process input (List.length options) choice cols in (* Computing the new choice *)
          if (input = ENTER) then
            if (!((get_command menu choice).state) = Cmd.DISABLED) then aux choice
            else run_command menu choice  (* Running the selected option *)
          else if (input = QUIT) then ()  (* Otherwise, displaying the updated menu *)
          else aux new_choice
      )) in aux 1

let back_to_menu () : unit =
  let open Private in
    print_endline ("\n\n" ^ (centered "Press Enter key (⏎) to go back to the previous menu"));
    let rec aux () : unit =
      let input : Input.t = Input.get () in
      match input with 
      | ENTER -> show (get_menu ())
      | _ -> aux () in
    aux ()
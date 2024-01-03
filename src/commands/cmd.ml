type t_state = IMPORTANT | DISABLED | ENABLED ;;
type t = { name : string ; f : (unit -> unit) ; state : t_state ref} ;;

let set_state (cmd : t) (state : t_state) : unit = (cmd.state) := state ;;

let run (cmd : t) : unit = cmd.f () ;;
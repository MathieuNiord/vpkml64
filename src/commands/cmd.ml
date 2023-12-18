type t = string * (unit -> unit)

let get_name (cmd : t) : string = let (name, _) = cmd in name ;;
let get_fun (cmd : t) : (unit -> unit) = let (_, f) = cmd in f ;;
let run (cmd : t) : unit = (get_fun cmd) () ;;
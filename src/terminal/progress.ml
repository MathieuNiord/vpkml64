type t = { total : int; mutable current : int } ;;

let create (total : int) : t = { total; current = 0 } ;;

let increment (bar : t) : unit =
  if bar.current < bar.total then bar.current <- bar.current + 1
;;

let round x = floor (x +. 0.5) ;;

let print (bar : t) (text : string option) : unit  =
  let percentage = (bar.current * 100) / bar.total in
  let progress = String.make (percentage / 2) '#' in
  let remaining = String.make (int_of_float (round ((100. -. float_of_int percentage) /. 2.))) '-' in
  let info : string = match text with
    | Some text -> Printf.sprintf "[%s] " (Standardizer.standardize text 15)
    | None -> ""
  in Printf.printf ("\r%s [%s%s] %d%%") info progress remaining percentage;
  flush_all ()
;;
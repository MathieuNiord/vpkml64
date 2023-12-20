let create_directory (dir : string) : unit =
  let is_dir : bool =
    try Sys.file_exists dir
    with Sys_error _ -> false
  in
    if is_dir then ()
    else
      try
        Sys.mkdir dir 0o644 (* 0o755 = read-only permission *);
        Unix.sleepf 0.5;
      with Sys_error _ -> ()

let read_file (path : string) : string =
  let ic : in_channel = open_in path
  in
  let rec aux () : string =
    try
      let line : string = (input_line ic)
      in line ^ "\n" ^ (aux ())
    with End_of_file -> close_in ic ; ""
  in aux ()
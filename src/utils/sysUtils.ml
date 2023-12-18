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
      with Sys_error _ -> ();;
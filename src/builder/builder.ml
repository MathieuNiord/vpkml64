open Sys
open Game
open Config

let fmtPath (s: string): string = "\"" ^ s ^ "\""

let icon_path (game : Game.t)     : string = (Game.icon_path game) ^ ".png" ;;
let bg_path (game : Game.t)       : string = (Game.bg_path game) ^ ".png" ;;
let startup_path (game : Game.t)  : string = (Game.startup_path game) ^ ".png" ;;

(* Builds args.txt file needed for building a vpk. *)
let buildArgs (game : Game.t) : unit =
  let oc = open_out args_path in (
    Printf.fprintf oc "%s" (Game.rom_path game) ;
    close_out oc
  )
;;

(* Builds param.sfo file needed for building a vpk. *)
let buildParamSfo (game : Game.t) : unit =
  let cmd : string = Printf.sprintf "%s -s TITLE_ID=%s %s %s"
    (mksfoex_path)
    (fmtPath (id game))
    (fmtPath (title game))
    (fmtPath param_path)
  in let _ =  command cmd in ()
;;

(* Final build *)
let buildVpk (game : Game.t) : unit =
  let cmd : string = Printf.sprintf "%s -s %s -b %s %s -a %s=\"sce_sys/icon0.png\" -a %s=\"sce_sys/livearea/contents/bg.png\" -a %s=\"sce_sys/livearea/contents/startup.png\" -a %s=\"sce_sys/livearea/contents/template.xml\" -a %s=\"args.txt\""
    (packvpk_path) (fmtPath param_path) (fmtPath eboot_path) (fmtPath (vpks_path ^ (title game) ^ ".vpk"))
    (fmtPath (icon_path game)) (fmtPath (bg_path game)) (fmtPath (startup_path game))
    (fmtPath template_path) (fmtPath args_path)
  in let _ = command cmd in ()
;;

let clean (game : Game.t) : unit =
  remove args_path;
  remove param_path;
  remove (icon_path game);
  remove (bg_path game);
  remove (startup_path game);
  rmdir (Game.tmp_path game) ;;

let clean_tmp () : unit =
  let dirs : string list = Sys.readdir tmp_path |> Array.to_list in
  let _ = List.map (fun dir -> rmdir (tmp_path ^ dir)) dirs in
  let _ = rmdir tmp_path in ()
;;

let build (game : Game.t) : unit =
  let _ = buildArgs game
  and _ = buildParamSfo game
  and _ = buildVpk game in ()
;;
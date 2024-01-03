let check_game (game : Game.t) : bool =
  match Repository.find (Game.slug game) with
  | Some _ -> true
  | None -> false
;;

let check_asset (asset : Assets.t_asset_type) (game : Game.t) : bool =
  match Repository.find_asset (Game.slug game) asset with
  | Some _ -> true
  | None -> false
;;

let check (game : Game.t) : bool =
  check_game game
  && check_asset Assets.ICON game
  && check_asset Assets.BG game
  && check_asset Assets.LOGO game
;;

let check_all (games : Game.t list) : Game.t list = List.filter check games ;;
let cmds = [
  Cmd_scrap.cmd;
  Cmd_build.cmd;
  Cmd_update_list.cmd;
  Cmd_update_medias.cmd;
  Cmd_credits.cmd;
]

let home_menu = Menu.create "Home" cmds

let () =
  Menu.show home_menu ;
  Builder.clean_tmp ()
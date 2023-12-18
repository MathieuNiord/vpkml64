(* === Scrapping configuration === *)
(* Scrapped results output *)
let scrapped_path = ".\\db\\"
(* ================================ *)


(* === Pathes configuration === *)

(* Game assets configuration *)
let img_icon_name : string = "icon0"
let img_bg_name   : string = "bg"
let img_logo_name : string = "startup"
let media_ext     : string = "png"

(* Tierce builder programs configuration *)
let convert_path  : string = ".\\bin\\convert.exe"        (* Convert image to png *)
let mogrify_path  : string = ".\\bin\\mogrify.exe"        (* Resize image *)
let pngquant_path : string = ".\\bin\\pngquant.exe"       (* Reduce color palelet of image *)
let mksfoex_path  : string = ".\\bin\\vita-mksfoex.exe"   (* Create param.sfo file *)
let packvpk_path  : string = ".\\bin\\vita-pack-vpk.exe"  (* Build eboot.bin and create .vpk folder with assets *)

(* Folders traveling configuration *)
let assets_path   : string = ".\\res\\assets\\"
let vpks_path     : string = ".\\res\\vpks\\"
let tmp_path      : string = ".\\res\\.tmp\\"
let vita_path     : string = "ux0:data/DaedalusX64/Roms/"

(* Vpk file builder configuration *)
let args_path     : string = tmp_path ^ "args.txt"
let param_path    : string = tmp_path ^ "param.sfo"
let eboot_path    : string = ".\\res\\eboot.bin"
let template_path : string = ".\\res\\template.xml"

(* Other resources *)
let title_path      : string = ".\\res\\title"
let credits_path    : string = ".\\res\\credits"

(* ============================ *)

(* === User Configuration (To place in another config file written in json) === *)
let rom_folder = ".\\roms\\"
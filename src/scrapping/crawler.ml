open Cohttp_lwt_unix
open Lwt.Infix
open Soup
open Soup.Infix

type t_element = Element of string | Elements of string [@@warning "-37"] ;;

(* Get the HTML body of the page url *)
let body (url : string) : string Lwt.t =
  Client.get (Uri.of_string url) >>= fun (_, body) ->
    body |> Cohttp_lwt.Body.to_string >|= fun body -> body
;;

(*  Traveling through HTML document the way you need,
    Must finished on a unique element *)
let browse_element (traveling : t_element list) (soup : soup node) : element node =
  match traveling with
  | fst::rest -> (
    match fst with
    | Element e ->
      let rec aux (nodes : t_element list) (cur : element node) : element node =
        match nodes with
        | [] -> cur
        | h::t -> match h with
          | Element e -> aux t (cur $ e)
          | Elements _ -> failwith "Can't travel on several elements"
      in aux rest (soup $ e)
    | Elements _ -> failwith "Can't travel on several elements"
  )
  | [] -> failwith "No nodes to travel"
;;

(*  Traveling through HTML document the way you need,
    Must finished on several elements recovering (example: <li> elements of a <ul>) *)
let browse_elements (traveling : t_element list) (soup : soup node) : element nodes =
  match traveling with
  | fst::rest -> (
    match fst with
    | Element e ->
      let rec aux (nodes : t_element list) (cur : element node) : element nodes =
        match nodes with
        | [] -> failwith "No nodes to travel"
        | h::t -> match h with
          | Element e -> aux t (cur $ e)
          | Elements els -> (cur $$ els)
      in aux rest (soup $ e)
    | Elements e -> (soup $$ e)
  )
  | [] -> failwith "No nodes to travel"
;;

(* Download a file from an url *)
let download_file url output_file =
  let ext : string = Filename.extension url in 
  Client.get (Uri.of_string url) >>= fun (_, body) ->
    Cohttp_lwt.Body.to_string body >>= fun body_string ->
      Lwt_io.with_file
        ~mode:Lwt_io.Output
        ~flags:[Unix.O_WRONLY; Unix.O_CREAT; Unix.O_TRUNC]
        ~perm:0o666
        (output_file ^ "." ^ ext)
        (fun channel -> Lwt_io.write channel body_string)
;;
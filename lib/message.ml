open Lwt.Syntax
module T = Caqti_type

let add_message req ~message =
  let query =
    let open Caqti_request.Infix in
    (T.string ->. T.unit) "insert into message (content) values ($1);"
  in
  Dream.sql req (fun (module Db) ->
    let* unit_or_error = Db.exec query message in
    Caqti_lwt.or_fail unit_or_error)
;;

let message req =
  let open Lwt.Syntax in
  let* form = Dream.form ~csrf:false req in
  match form with
  | `Ok [ ("message", message) ] ->
    let* _ = add_message req ~message in
    Stdlib.Printf.sprintf "<div>%s</div>" message |> Dream.html
  | _ -> Dream.empty `Bad_Request
;;

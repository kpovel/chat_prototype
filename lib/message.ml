open Base
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
  let* form = Dream.form ~csrf:false req in
  match form with
  | `Ok [ ("message", message) ] ->
    let* _ = add_message req ~message in
    Stdlib.Printf.sprintf "<div>%s</div>" message |> Dream.html
  | _ -> Dream.empty `Bad_Request
;;

let message_range req =
  match Dream.query req "start", Dream.query req "end" with
  | Some startp, Some endp ->
    let startp = Int.of_string startp in
    let endp = Int.of_string endp in
    let rec until startp endp =
      match startp <= endp with
      | true ->
        let* _ = add_message req ~message:(Int.to_string startp) in
        until (startp + 1) endp
      | false -> Lwt.return ()
    in
    let* _ = until startp endp in
    Dream.empty `OK
  | _ -> Dream.empty `Bad_Request
;;

open Base
open Lwt.Syntax
module T = Caqti_type

let add_message req ~message =
  let query =
    let open Caqti_request.Infix in
    (T.string ->! T.(tup2 int string))
      "insert into message (content) values (:message) returning id, sent_at;"
  in
  Dream.sql req (fun (module Db) ->
    let* unit_or_error = Db.find query message in
    Caqti_lwt.or_fail unit_or_error)
;;

let send_message req =
  let* form = Dream.form ~csrf:false req in
  match form with
  | `Ok [ ("message", message) ] ->
    let* id, _sent_at = add_message req ~message in
    Index.message ~m:message ~id |> Dream_html.respond
  | _ -> Dream.empty `Bad_Request
;;

let message_pagination_query req ~id =
  let query =
    let open Caqti_request.Infix in
    (T.int ->* T.(tup3 int string string))
      "select id, content, sent_at\n\
       from message\n\
       where id < $1\n\
       order by id desc\n\
       limit 20;"
  in
  Dream.sql req (fun (module Db) ->
    let* messages = Db.collect_list query id in
    Caqti_lwt.or_fail messages)
;;

let message_pagination req =
  let query = Dream.query req "id" in
  match query with
  | None -> Dream.empty `Bad_Request
  | Some id ->
    let id = Int.of_string id in
    let* messages = message_pagination_query req ~id in
    let open Dream_html in
    let open HTML in
    List.map messages ~f:(fun (id, content, _sent_at) -> Index.message ~m:content ~id)
    |> null
    |> Dream_html.respond
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

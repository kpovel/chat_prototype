let message req =
  let open Lwt.Syntax in
  let* form = Dream.form ~csrf:false req in
  match form with
  | `Ok [ ("message", message) ] ->
    Stdlib.Printf.sprintf "<div>%s</div>" message |> Dream.html
  | _ -> Dream.empty `Bad_Request
;;

open Base
open Lwt.Syntax
module T = Caqti_type

let messages req =
  let query =
    let open Caqti_request.Infix in
    (T.unit ->* T.(tup3 int string string)) "select id, content, sent_at from message;"
  in
  Dream.sql req (fun (module Db) ->
    let* messages = Db.collect_list query () in
    Caqti_lwt.or_fail messages)
;;

let message ~m =
  let open Dream_html in
  let open HTML in
  div [] [ txt "%s" m ]
;;

let index_page req =
  let open Dream_html in
  let open HTML in
  let open Lwt.Syntax in
  let* messages = messages req in
  Lwt.return
    (html
       []
       [ head
           []
           [ meta [ charset "UTF-8" ]
           ; meta [ name "viewport"; content "width=device-width, initial-scale=1.0" ]
           ; script [ src "https://cdn.tailwindcss.com" ] ""
           ; script [ src "/js/index.js"; defer ] ""
           ]
       ; main
           [ class_ "flex flex-col h-dvh" ]
           [ header
               [ class_ "bg-gray-200 p-2" ]
               [ h2 [ class_ "text-2xl" ] [ txt "chat name" ] ]
           ; section
               [ class_
                   "grow m-2 border bg-pink-200 overflow-scroll flex flex-col-reverse"
               ; id "chat"
               ]
               (List.map messages ~f:(fun (_id, content, _sent_at) -> message ~m:content)
                |> List.rev)
           ; section
               [ class_ "m-2" ]
               [ form
                   [ id "form" ]
                   [ input
                       [ class_ "border-2 border-gray-800 rounded w-full"
                       ; placeholder "Type a message"
                       ; name "message"
                       ]
                   ]
               ]
           ]
       ])
;;

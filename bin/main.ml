open Chat_prototype
open Lwt

let () =
  Dream.run ~port:42069
  @@ Dream.logger
  @@ Dream.sql_pool "sqlite3:db/dev.db"
  @@ Dream.router
       [ Dream.get "/" (fun req -> Index.index_page req >>= Dream_html.respond)
       ; Dream.post "/message" (fun req -> Message.send_message req)
       ; Dream.get "/message-pagination" (fun req -> Message.message_pagination req)
       ; Dream.get "/message-range" (fun req -> Message.message_range req)
       ; Dream.get "/js/**" @@ Dream.static "js"
       ]
;;

open Chat_prototype

let () =
  Dream.run ~port:42069
  @@ Dream.logger
  @@ Dream.router
       [ Dream.get "/" (fun req -> Index.index_page req |> Dream_html.respond)
       ; Dream.post "/message" (fun req -> Message.message req)
       ]
;;

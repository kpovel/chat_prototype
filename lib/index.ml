let index_page _req =
  let open Dream_html in
  let open HTML in
  html
    []
    [ head
        []
        [ meta [ charset "UTF-8" ]
        ; meta [ name "viewport"; content "width=device-width, initial-scale=1.0" ]
        ; script [ src "https://unpkg.com/htmx.org@1.9.12" ] ""
        ; script [ src "https://cdn.tailwindcss.com" ] ""
        ]
    ; main
        [ class_ "flex flex-col h-dvh" ]
        [ header
            [ class_ "bg-gray-200 p-2" ]
            [ h2 [ class_ "text-2xl" ] [ txt "chat name" ] ]
        ; section
            [ class_ "grow m-2 border bg-pink-200"; id "chat" ]
            [ txt "message list" ]
        ; section
            [ class_ "m-2" ]
            [ form
                [ Hx.post "/message"
                ; Hx.target "#chat"
                ; Hx.swap "beforeend"
                ; Hx.on_ ~event:":after-request" "this.reset()"
                ]
                [ input
                    [ class_ "border-2 border-gray-800 rounded w-full"
                    ; placeholder "Type a message"
                    ; name "message"
                    ]
                ]
            ]
        ]
    ]
;;

order = [ "presentation.html",
          "history-1.html"
          "history-2.html"
          "history-3.html"
          "history-3b.html"
          "history-3c.html"
          "history-4.html"
          "history-5.html"
          "history-6.html"
          "history-7.html"
        ]

url = document.baseURI.replace(/^.*\/([^\/]+)/, "$1")
idx = order.indexOf(url)
next = order[idx + 1]

advancePage = (event) ->
        console.log("Got: ", event.keyCode)
        if event.keyCode == 32
                location.assign(next)

$("body").keypress(advancePage)

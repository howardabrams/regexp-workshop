order = [ "presentation.html",
          "01-the-magic.html",
          "02-hey-programmer.html",
          "03-how-would-you.html",
          "04-regular-expressions-good.html",
          "05-regular-expressions-bad.html",
          "06-your-toolbox.html",
          "history-1.html",
          "history-2.html",
          "history-3.html",
          "history-3b.html",
          "history-3c.html",
          "history-4.html",
          "history-5.html",
          "history-6.html",
          "history-7.html",
          "08-history-takeaways.html",
          "09-exploring-workshop.html",
          "10-workshop-first-pass.html",
          "10-workshop-first-pass-2.html",
          "11-metacharacters.html",
          "12-search-for-meta.html",
          "13-optional-searches.html",
          "14-or.html",
          "15-brackets.html",
          "16-character-types.html",
          "17-behaviors.html",
          "18-counting.html",
          "19-groupings.html",
          "20-replacing.html",
          "21-complete-list.html",
          "22-ultimate-spell.html",
          "23-extra-credit.html",
        ]

url = document.baseURI.replace(/^.*\/([^\/]+)/, "$1")
idx = order.indexOf(url)
next = order[idx + 1]

phase=1
total_phases=0

advancePage = (event) ->
        if event.keyCode == 32
                if phase > total_phases
                        location.assign(next)
                else
                        $(".stage-#{phase}").show()
                        phase = phase + 1

hideStages = ->
        for stage in [1..20]
                if $(".stage-#{stage}").size() > 0
                        $(".stage-#{stage}").hide()
                        total_phases=stage

        console.log("Hid only #{total_phases} sections")

$("body").keypress(advancePage)

$(->
        hideStages()
)

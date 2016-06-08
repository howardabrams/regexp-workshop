editor = null
content = null
gotcode = false
triggered = false

loadText = ->
        name = $("#which-text").val()
        $.ajax("data/#{name}.html", {
                dataType: "html",
                error: -> $.ajax("data/#{name}", {
                                success: (data) ->
                                        gotcode = true
                                        content = escapeHTML(data)
                                        displayContent(content, true)
                        }),
                success: (data) ->
                        gotcode = false
                        content = data
                        displayContent(content, false)
        })


clearRegExp = (s) -> s.replace(/\s+|\s*#\s.*$/gm, "")
escapeHTML  = (s) -> s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")

displayContent = (text, codep = gotcode) ->
        if (codep)
                $("#example-section").html(text).wrapInner("<pre>")
        else
                $("#example-section").html(text)
        gotcode = codep

formatTitle = (e, idx) ->
        i = idx + 1
        "$#{i}: #{e}"

matchedReplacement = (match, groups..., idx, fulltext) ->
        # console.log("Matched:", match, "Groups:", groups, "Index:", idx)
        title = (formatTitle(e,idx) for e,idx in groups).join(" ")
        "<span class='highlighted' title='#{title}'>#{match}</span>"

        # The following, while more idiomatic jQuery, screws up
        # matching on HTML documents. Oh well:
        # $("<span>").addClass("highlighted").attr("title", title).text(match).prop("outerHTML")

# Triggered by the "Run" button to execute the SQL and display the results.
runCode_Button = ->
        triggered = true
        runCode()

runCode_Auto = ->
        triggered = false
        runCode()

runCode = ->
        ws = $("#whitespace").is(":checked")
        ci = $("#insensitive").is(":checked")

        re = if ws
                clearRegExp(editor.getValue())
             else
                editor.getValue()

        console.log("Regexp Query:", re, ci, ws)
        try
                if re == ""
                        displayContent(content)
                else
                        patt = new RegExp(escapeHTML(re), (if ci then "gi" else "g"))
                        displayContent( content.replace(patt, matchedReplacement) )
        catch error
                if triggered
                        alert(error)
                else
                        console.log(error)

readjustViewport = ->
        sectionHeight = $("body").innerHeight() - $("h1").height() * 2
        $("#instructions").height(sectionHeight)

$(->
    # Readjust the height of the instructions:
    # readjustViewport()
    loadText()

    if ($("span.subtitle").height() > $("span.title").height())
            $("span.subtitle").html("Workshop")

    # INITIALIZATION: Based on the anchor reference (the HTML's hash
    # tag), we download the instructions and preload the database:

    # EVENTS:
    $(window).resize(readjustViewport)
    $("#run-code").click(runCode_Button)
    $("#which-text").change(loadText)
    $("#whitespace").change(runCode_Button)
    $("#insensitive").change(runCode_Button)

    # Configure the ACE Editor: https:#ace.c9.io
    editor = ace.edit("editor")
    # dawn is light blueish
    # clouds is yellow
    # eclipse is a purple on light blue
    # solarized_light is ochre
    editor.setTheme("ace/theme/merbivore_soft")   # dawn
    # editor.getSession().setMode("ace/mode/javascript")
    editor.gotoLine(1)
    editor.$blockScrolling = Infinity
    editor.setHighlightActiveLine(false)
    editor.setHighlightSelectedWord(true)

    # Attempt to un-select the text that is loaded...
    # range = new Range(0,0,0,0)
    # editor.addSelectionMarker(range)

    delay = 1000 # 1 seconds delay after last input
    editorTimer = null

    editorKeyup = ->
        clearTimeout(editorTimer)
        editorTimer = setTimeout(runCode_Auto, delay)

    $('#editor').bind('input keyup', editorKeyup)
)

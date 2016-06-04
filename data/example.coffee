editor = null
dynatable = null

# Download and display the HTML instructions for a given project project
loadInstructions = (project) ->
        file = "data/" + project + "/index.html"
        $("#instructions").load(file, -> hideAnswers())

hideAnswers = ->
        $(".hidden").after('<button class="answer">Answer</button>')
        $(".hidden").hide()
        $(".answer").click ->
                codeblk = $(this).hide().prev(".hidden")
                codeblk.after('<button class="copy">Copy</button>')
                codeblk.show("slow").each(
                        (i, block) -> hljs.highlightBlock(block) )
                $(".copy").click(copyAnswer)

copyAnswer = ->
        editor.setValue( $(this).prev(".hidden").text() )

# Download and insert into the Editor an initialization script
loadInitialCode = (project) ->
        file = "data/" + project + "/init.sql"
        $.get(file, (data) ->
                editor.setValue(data.replace /^\s+|\s+$/g, ""))

loadRow = (database, row, id) ->
        if not row.id
                row.id = id
        alasql('INSERT INTO ' + database + ' VALUES ' + JSON.stringify(row))

# Given a database table name and a filename, create the table and
# insert the contents of the CSV into the SQL table.
loadDatabase = (project, database, filename, schema) ->
        file = "data/" + project + "/" + filename
        console.log("Loading database", database, file, schema)
        alasql('CREATE TABLE ' + database + schema)
        # Accept data types for the CSV, as in:
        # (
        #   date DATE,
        #   start_time DATETIME,
        #   end_time DATETIME
        # )
        alasql('SELECT * FROM CSV("' + file + '",{headers:true})',[],
                (data) ->
                        console.log("Database", data)
                        ( loadRow(database, row, id) for row,id in data ))

# Downloads the 'database.json' file that has a collection key/value
# that specify the database table name and the CSV table to get its contents
loadDatabases = (project) ->
        file = "data/" + project + "/database.json"
        console.log("Loading Database JSON", file)
        $.get(file, (data, status) ->
                if typeof data is 'string'
                        dbs = JSON.parse(data)
                else
                        dbs = data
                console.log(status + " in downloading:", dbs)
                ( loadDatabase(project, db.database, db.file,
                               db.schema) for db in dbs ))

# Converts a string to an initial capital letter. Used for Table Headers
toTitleCase = (str) ->
        if str == "id"
                "ID"
        else
                str.replace(/\w\S*/g, (txt) ->
                        txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase())

# Given a row of key/value pairs of a single database record, extract
# the keys and return an HTML string of the keys as headers.
extractHeader = (row) ->
        console.log("Creating new row: ", row)
        "<thead>" +
        ( "<th>" + toTitleCase(key) + "</th>" for key,v of row).join("") +
        "</thead><tbody><td </tbody>"

# Triggered by the "Run" button to execute the SQL and display the results.
runCode = ->
        sql = editor.getValue()
        console.log("SQL Query", sql)
        try
            records = alasql(sql)
            console.log("SQL Records", records)
            if (records[0])
                    headers = extractHeader(records[0])
                    $("#results-table").remove()
                    $("#results-section").html("<table id='results-table'></table>")
                    $("#results-table").html(headers)
                    $('#results-table').bind('dynatable:init', (e,dynatable) ->
                            console.log(dynatable.utility)
                            dynatable.utility.textTransform.tox = (text) ->
                                    console.log("Huh", text)
                                    text.replace(/a/, 'x')
                    ).dynatable({
                            dataset: {
                                    records: records
                            }
                    })
        catch error
                $("#results-section").html("<div class='error'>#{error}</div>")

readjustViewport = ->
        sectionHeight = $("body").innerHeight() - $("h1").height() * 2
        $("#instructions").height(sectionHeight)

$(->
    # Readjust the height of the instructions:
    readjustViewport()

    # INITIALIZATION: Based on the anchor reference (the HTML's hash
    # tag), we download the instructions and preload the database:
    database = location.hash.substring(1)
    loadInstructions(database)
    loadInitialCode(database)
    loadDatabases(database)

    # EVENTS:
    $(window).resize(readjustViewport);
    $("#run-code").click(runCode)

    $.dynatableSetup({
            features: {
                          search: false
            }
    })

    # Configure the ACE Editor: https:#ace.c9.io
    editor = ace.edit("editor")
    # dawn is light blueish
    # clouds is yellow
    # eclipse is a purple on light blue
    # solarized_light is ochre
    editor.setTheme("ace/theme/merbivore_soft")   # dawn
    editor.getSession().setMode("ace/mode/sql")
    editor.gotoLine(1)
    editor.$blockScrolling = Infinity
    editor.setHighlightActiveLine(true)
    editor.setHighlightSelectedWord(true)

    # Attempt to un-select the text that is loaded...
    # range = new Range(0,0,0,0)
    # editor.addSelectionMarker(range)

)

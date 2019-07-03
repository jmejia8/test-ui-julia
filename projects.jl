using Blink
import JSON

function main_projects()
    w = Window(async=false);
    title(w, "My Projects")

    load!(w, "materialize/js/materialize.js")
    load!(w, "materialize/css/materialize.min.css")
    load!(w, "materialize/icons.css")

    body!(w, read("projects.html", String))



    # handle(w, "init") do args
    #     println("Initializing...")
    #     init(w)
    # end

    load!(w, "engine.js")
    load!(w, "style.css")

end

main_projects()
function init(w)
    
end


function main_runProject(json_name)
    w = Window(async=false);
    title(w, "My Projects")

    load!(w, "materialize/js/materialize.js")
    load!(w, "materialize/css/materialize.min.css")
    load!(w, "materialize/icons.css")

    body!(w, read("runProject.html", String))

    load!(w, "engine.js")
    load!(w, "style.css")



    handle(w, "init") do args
        println("Initializing...")
        init(w)

        @js_ w begin
            document.getElementById("tmp").innerHTML = $json_name
        end

        for i = 1:10
            p = i * 10.0
            txt = "width: $p%;"
            println(txt)
            @js_ w begin
                document.getElementById("progress").style = $txt
            end
            sleep(1)
        end
    end

end


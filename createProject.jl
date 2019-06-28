using Blink

function createProject(name, target, distributed)

    if isdir(name)
        return false
    end

    try
        mkdir(name)
    catch
        return false
    end

    return true
end

function init(w)
    n = Sys.CPU_THREADS
    txt = string("", n)

    @js_ w begin
        # @var a = $txt
        @var tr = document.getElementById("threads")

        tr.innerHTML = $txt
    end
end



function main()
    w = Window(async=false);
    load!(w, "materialize/js/materialize.js")
    load!(w, "materialize/css/materialize.min.css")

    body!(w, read("createProject.html", String))



    handle(w, "init") do args
        println("perro")
        init(w)
    end

    load!(w, "engine.js")

    handle(w, "createProject") do args
        
        if length(args) != 3
            @error "Error"
            return 
        end

        if !createProject(args...)

            @js_ w begin

                alert("Invalid infromation")
            end
        end


    end

end

main()
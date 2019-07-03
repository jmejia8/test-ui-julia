using Blink
import JSON

function createProject(project_json)
    myhomepath = joinpath( homedir(), ".bcap")
    projectpath = joinpath(myhomepath, "projects")

    if !isdir(myhomepath)
        try
            mkdir(myhomepath)
            mkdir(projectpath)
        catch
            return Dict("error" => true, "msg"=> "Error creating folder.")
        end
    end

    prj_name = string(project_json["project-name"], ".json")
    for s = [ "/", "\\", " "]
        prj_name = replace(prj_name, s => "-")
    end

    prj_name = joinpath(projectpath, prj_name)

    if isfile(prj_name)
        return Dict("error" => true, "msg"=> "Existing Project.")
    end


    open(prj_name,"w") do f 
        JSON.print(f, project_json)
    end

    display(project_json)
    return Dict("error" => false, "msg" => "Project saved.")

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



function main_createProject()
    w = Window(async=false);
    title(w, "New BCAP project")
    progress(w, 0.5)

    load!(w, "materialize/js/materialize.js")
    load!(w, "materialize/css/materialize.min.css")
    load!(w, "materialize/icons.css")

    body!(w, read("createProject.html", String))



    handle(w, "init") do args
        println("Initializing...")
        init(w)
    end

    load!(w, "engine.js")
    load!(w, "style.css")

    handle(w, "createProject") do args
        
        if length(args) != 3
            @error "Error"
            return 
        end

        if !createProject(args...)

            @js_ w begin

                alert("Check Project Name.")
            end
        end


    end

    handle(w, "saveProject") do project_json
        res = createProject(project_json)
        display(res)
        if res["error"]
            msg = res["msg"]
            @js_ w begin
                alert($msg)
            end
        else
            @js_ w begin
                @var r = confirm("Start tuning?");
                if r
                    window.close()                    
                end
            end
        end
    end




end

# main_createProject()
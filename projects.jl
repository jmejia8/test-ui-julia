using Blink
import JSON

include("utils.jl")
include("createProject.jl")
include("runProject.jl")

function jsonToHTML(json_name)
    json = JSON.parsefile(json_name)

    str = """
          <tr>
            <td>$(json["project-name"])</td>
            <td>$(json["target-algorithm-name"])</td>
            <td>$(length(json["parameters"]["parameters"]))</td>
            <td>
                <a class="waves-effect waves-light btn" onclick="Blink.msg('runProject', '$(json_name)')">Run</a>
                <a class="waves-effect waves-light btn" onclick="Blink.msg('editProject', '$(json_name)')">Edit</a>
            </td>
          </tr>
    """; 
    
end

function init(w)
    myhomepath = joinpath( homedir(), ".bcap")
    projects_path = joinpath(myhomepath, "projects")

    check_home_directory(myhomepath, projects_path)

    str = ""

    for fname in readdir(projects_path)
        str = string(str, jsonToHTML(joinpath(projects_path, fname)))
    end

    @js_ w begin
        @var box = document.getElementById("my-projects")
        
        box.innerHTML = $str
    end
end

function main_projects()
    w = Window(async=false);
    title(w, "My Projects")

    load!(w, "materialize/js/materialize.js")
    load!(w, "materialize/css/materialize.min.css")
    load!(w, "materialize/icons.css")

    body!(w, read("projects.html", String))



    handle(w, "init") do args
        println("Initializing...")
        init(w)
    end

    handle(w, "newProject") do args
        main_createProject()

        @js w begin
            window.close()
        end
    end

    handle(w, "runProject") do json_name
        println(json_name)

        main_runProject(json_name)
        @js w begin
            window.close()
        end
    end

    load!(w, "engine.js")
    load!(w, "style.css")

end

main_projects()
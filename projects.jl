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
                <a href="#" class="tooltipped" data-position="bottom" alt="Run project" onclick="Blink.msg('runProject', '$(json_name)')"><i class="small material-icons" style="color:#242D34;">play_circle_outline</i></a>
                <a href="#" class="tooltipped" data-position="bottom" alt="Edit project" onclick="Blink.msg('editProject', '$(json_name)')"><i class="small material-icons" style="color:#242D34;">edit</i></a>
                <a href="#" class="tooltipped" data-position="bottom" alt="Remove project" onclick="removeProject('$(json_name)', '$(json["project-name"])')"><i class="small material-icons" style="color:#D56969;">delete</i></a>
            </td>
          </tr>
    """; 
    
end

function projects_init(w)
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
        projects_init(w)
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

    handle(w, "editProject") do json_name

        main_createProject(json_name)
        @js w begin
            window.close()
        end
    end

    handle(w, "removeProject") do json_name
        println("Trying to remove: ", json_name)
        removed = false
        try
            rm(json_name)
            removed = true
        catch
            removed = false
        end

        if !removed
            @js w begin
                alert("Fail removing project")
            end
        else
            main_projects()
            @js w begin
                window.close()
            end
        end



        
    end
    

    load!(w, "engine.js")
    load!(w, "style.css")

end

main_projects()
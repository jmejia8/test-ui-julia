function createProject(project_json, overwrite=false)
    myhomepath = joinpath( homedir(), ".bcap")
    projects_path = joinpath(myhomepath, "projects")

    if !check_home_directory(myhomepath, projects_path)
        return Dict("error" => true, "msg"=> "Error creating folder.", "code" => 0)
    end

    prj_name = string(project_json["project-name"], ".json")
    for s = [ "/", "\\", " "]
        prj_name = replace(prj_name, s => "-")
    end

    prj_name = joinpath(projects_path, prj_name)

    if !overwrite &&  isfile(prj_name)
        return Dict("error" => true, "msg"=> "Existing Project.", "code" => 1)
    end


    open(prj_name,"w") do f
        JSON.print(f, project_json)
    end

    display(project_json)
    return Dict("error" => false, "msg" => "Project saved.", "code" => 2)

end

function createProject_init(w, json_name)
    n = Sys.CPU_THREADS
    txt = string("", n)

    @js_ w begin
        # @var a = $txt
        @var tr = document.getElementById("threads")

        tr.innerHTML = $txt
    end


    # ============
    if !isnothing(json_name) && isfile(json_name)
        editProject(w, json_name)
    end
end

function editProject(w, json_name)
    json = JSON.parsefile(json_name)
    println("editProject")
    @js_ w begin
        projectToHTML($json)
    end
end

function main_createProject(json_name  = nothing)
    w = Window(async=false);
    title(w, "New BCAP project")
    progress(w, 0.5)

    load!(w, "assets/materialize/js/materialize.js")
    load!(w, "assets/materialize/css/materialize.min.css")
    load!(w, "assets/materialize/icons.css")

    body!(w, read("components/createProject/createProject.html", String))



    handle(w, "init") do args
        println("Initializing...")
        createProject_init(w, json_name)
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
        res = createProject(project_json, !isnothing(json_name))
        display(res)
        if res["error"]
            msg = res["msg"]
            @js_ w begin
                alert($msg)
                getById("save-btn").disabled = false;
                getById("save-btn").innerHTML = "Retry";
            end
        else
            @js_ w begin
                getById("save-btn").disabled = true;
                getById("save-btn").innerHTML = "Project saved!";
            end
            sleep(5)
            @js_ w begin
                getById("save-btn").disabled = false;
                getById("save-btn").innerHTML = "Save project";
            end
            # main_projects()
        end
    end


    handle(w, "chooseDirectory") do str
        println("------------")

        file = ""

        try
            file = replace(read(`zenity --directory --file-selection`, String), "\n" => "")
        catch

        end
        @show(file)
        if isdir(file)
            @js_ w begin
                document.getElementById($str).value = $file
            end
        else
            @js_ w begin
                alert("Error opening disrectory")
            end
        end
    end

    handle(w, "gotoProjects") do str
        main_projects()
        @js_ w begin
            window.close()
        end
    end

    handle(w, "chooseFile") do str
        println("------------")
        file = ""

        try
            file = replace(read(`zenity --file-selection`, String), "\n" => "")
        catch

        end
        @show(file)

        if isfile(file)
            @js_ w begin
                document.getElementById($str).value = $file
            end
        else
            @js_ w begin
                alert("Error opening file")
            end
        end
    end




end

# main_createProject()



function init_run(w)

end

@everywhere function shell_target(Φ, instance, seed=0; exe = "", flags = String[], seed_flag="--seed")
    if isempty(flags)
        error("Configure your target runner.")
        return 0
    end

    vals = string.(Φ) .* " "
    exe_name = exe
    settings = (flags .* vals)
    instance_str = instance[:instance]

    cmd = string(exe_name, " ", prod(settings), instance_str, " ", seed_flag, " ", string(seed))
    cmd  = split(cmd)

    fx = 1e6

    try
        fx = parse(Float64, read(`$cmd`, String))
    catch
        @warn("Target algorithm fail, penalizing result 1e6.")
        println(`$cmd`)
        fx = 1e6
    end

    if haskey(instance, :optim) && instance[:optim] >= 0
        if fx <= instance[:optim]
            return 0.0
        end
        return fx
    end

    return fx

end


@everywhere function repl_target(Φ, instance, seed=0; src_path = nothing)
    if isnothing(src_path) || !isfile(src_path)
        error("Choose a valid julia file")
        return NaN
    end

    ff = include(src_path)
    fx = ff(Φ, instance, seed)

    if haskey(instance, :optim) && instance[:optim] >= 0
        if fx <= instance[:optim]
            return 0.0
        end
        return fx
    end

    return fx

end


function getTargetAlgorithm_CMD(json)
    bounds = zeros(2, length(json["parameters"]["parameters"]))
    parmstype = DataType[]
    flags = String[]

    i = 1
    for item in json["parameters"]["parameters"]
        if item["type"] == "float"
            push!(parmstype, Float64)
            bounds[1, i], bounds[2, i] = parse.(Float64, split(item["values"], ","))
        elseif item["type"] == "int"
            push!(parmstype, Int)
            bounds[1, i], bounds[2, i] = parse.(Int, split(item["values"], ","))
        elseif item["type"] == "categorical"
            push!(parmstype, Int)
            bounds[1, i], bounds[2, i] = parse.(Int, split(item["values"], ","))
        elseif item["type"] == "bool"
            push!(parmstype, Bool)
            bounds[1, i], bounds[2, i] = parse.(Int, split(item["values"], ","))
        else
            error("Check values")
        end

        push!(flags, json["parameters"]["prefix"] * item["flag"] * json["parameters"]["sep"])

        i += 1
    end


    targetAlgorithm(Φ, instance, seed = 0) = begin

        if json["target-algorithm-src"] != "repl"
            return shell_target(Φ, instance, seed;
            exe = json["target-algorithm-path"],
            flags = flags,
            seed_flag="--seed")
        else
            return repl_target(Φ, instance, seed; src_path=json["target-algorithm-path"])
        end
    end

    return bounds,parmstype, targetAlgorithm
end

function loadInstances(w, json, BCAP_meta)
    @info "loadInstances"
    my_instances = nothing
    if !isempty(json["instances-file"])
        fname = joinpath(json["instances-path"], json["instances-file"])
    elseif !isempty(json["instances"])
        txt = "instance,optim\n"
        for instance in json["instances"]
            v = split(instance, ",")
            if length(v) >= 2
                txt *= string(v[1],",",v[2], "\n")
            else
                txt *= string(v[1],",-1", "\n")
            end
        end

        open("instances.txt","w") do io
           print(io, txt)
        end

        fname = "instances.txt"

    else
        @js_ w begin
            alert("No instances were provided")
        end
        error("No instances were provided")
    end

    if !isfile(fname)
        txt = "Error: cannot open file $fname"
        @js_ w begin
            alert($txt)
        end

        error(txt)
    end

    my_instances = CSV.read(fname)
    the_instances = Dict[]


    for i = 1:length(my_instances.instance)
        instance = Dict(:instance => json["instance-flag"] * joinpath(json["instances-path"], my_instances.instance[i]), :optim => my_instances.optim[i])
        push!(the_instances, instance)
    end

    display(the_instances)
    BCAP_meta["instances"] = the_instances

end

function sendInfoToUI(w, status, json)
    header_txt = map( str -> "<th>" * string(str["name"]) * "</th>", json["parameters"]["parameters"])
    body_txt = map( v -> "<td>" * string(v) * "</td>", status.best_sol.x)

    html_head = "<th>Iteration</th>" * prod(header_txt) * "<th>Instances Solved</th>" * "<th>Cost</th>"
    html_body = string("<td>" , status.iteration ,  "</td>") * prod(body_txt) * string("<td>", Int(sum(status.best_sol.y[:y] .== 0.0)), "</td>")
    html_body *= string("<td>", @sprintf("%.3e",status.best_sol.F) , "</td>")

    @js_ w begin
        document.getElementById("table-results-head").innerHTML = $html_head;
        document.getElementById("table-results-body").innerHTML += $html_body;
    end
end


function startingBCAP(w, json, BCAP_meta)
    @info "startingBCAP"
    bounds,parmstype, targetAlgorithm = getTargetAlgorithm_CMD(json)
    benchmark = BCAP_meta["instances"]

    display(bounds)
    display(parmstype)

    D_ = size(bounds, 2)
    K = 6

    BCAP_parms = BCAP(N = K*D_,
                        K = K,
                        parms_type = parmstype,
                        significant_digits = 6,
                        calls_per_instance = 1,
                        benchmark = benchmark,
                        seed = 1,
                        η_max = 1.2,
                        targetAlgorithm = targetAlgorithm
                        )

    options = Bilevel.Options(F_calls_limit=Inf,
                        f_calls_limit=json["target-runner-calls"]*length(benchmark),
                        F_tol=1e-5,
                        f_tol=1e-5,
                        store_convergence=false,
                        debug=true)

    information = Bilevel.Information(f_optimum=0.0)

    LL_optimizer(Φ,problem,status,information,options,t) = lower_level_optimizer(Φ,problem,status,information,options,t; parameters = BCAP_parms)

    update_state_w!(args...; w = w, json = json) = begin
        status = args[4]
        sendInfoToUI(w, status, json)

        update_state!(args...)
    end

    final_stage_w!(args...; w = w, json = json) = begin
        final_stage!(args...)
        status = args[1]
        sendInfoToUI(w, status, json)
        @js_ w begin
            document.getElementById("progress-container").style.display = "none";
        end
        println("done!")

    end

    method = Algorithm(BCAP_parms;
                initialize! = initialize!,
                update_state! = update_state_w!,
                final_stage! = final_stage_w!,
                lower_level_optimizer = LL_optimizer,
                is_better = is_better,
                stop_criteria = stop_criteria,
                information = information,
                options = options)

    BCAP_meta["method"] = method
    BCAP_meta["bounds"] = bounds
end

function configuring(w, json, BCAP_meta)
    @info("Running BCAP...")
    results = Bilevel.optimize(F, f, BCAP_meta["bounds"], BCAP_meta["bounds"], BCAP_meta["method"])
    BCAP_meta["status"] = results
end

function finishing(w, json, BCAP_meta)
    @info "finishing"
    status = BCAP_meta["status"]
    best = status.best_sol


    @js_ w begin
        document.getElementById("solved-instances").innerHTML = $(status.best_sol.f)
        document.getElementById("num-instances").innerHTML = $(length(status.best_sol.y[:ids]))
    end

    header_txt = map( str -> "<th>" * string(str["name"]) * "</th>", json["parameters"]["parameters"])
    body_txt = map( v -> "<td>" * string(v) * "</td>", status.best_sol.x)

    html_head = prod(header_txt)
    html_body = prod(body_txt)


    @js_ w begin
        document.getElementById("table-best-results-head").innerHTML = $html_head;
        document.getElementById("table-best-results-body").innerHTML += $html_body;
    end

end


function main_runProject(json_name)
    w = Window(async=false);
    title(w, "My Projects")

    load!(w, "assets/materialize/js/materialize.js")
    load!(w, "assets/materialize/css/materialize.min.css")
    load!(w, "assets/materialize/icons.css")

    body!(w, read("components/runProject/runProject.html", String))

    load!(w, "engine.js")
    load!(w, "style.css")



    handle(w, "init") do args
        println("Initializing...")
        init_run(w)

        json = JSON.parsefile(json_name)

        @js_ w begin
            document.getElementById("title").innerHTML = $(json["project-name"])
            document.getElementById("sub-title").innerHTML = $(json["target-algorithm-name"])
        end

        project_steps = [ loadInstances, startingBCAP, configuring, finishing ]

        BCAP_meta = Dict()

        for i = 1:length(project_steps)

            project_steps[i](w, json, BCAP_meta)

            p = (i/length(project_steps)) * 100.0
            txt = "width: $p%;"
            t = string(project_steps[i])
            @js_ w begin
                document.getElementById("progress").style = $txt
                document.getElementById($t).innerHTML = "Done!"
            end

        end
    end

end

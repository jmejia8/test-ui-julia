import CSV
include("/home/jesus/develop/repos/bca-parameter/BCAP.jl")

function init(w)
    
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
        o = fx - instance[:optim]
        if o < 0
            println("Check instance ")
            display(instance)
            error("Ill-posed benchmark")
            return 0
        end
        fx = o
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


    targetAlgorithm(Φ, instance, seed = 0) = shell_target(Φ, instance, seed;
        exe = json["target-algorithm-path"],
        flags = flags,
        seed_flag="--seed")


    return bounds,parmstype, targetAlgorithm
end

function loadInstances(w, json, BCAP_meta)
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

function staringBCAP(w, json, BCAP_meta)
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
                        f_calls_limit=50*length(benchmark),
                        F_tol=1e-5,
                        f_tol=1e-5,
                        store_convergence=false,
                        debug=true)

    information = Bilevel.Information(f_optimum=0.0)

    LL_optimizer(Φ,problem,status,information,options,t) = lower_level_optimizer(Φ,problem,status,information,options,t; parameters = BCAP_parms)

    method = Algorithm(BCAP_parms;
                initialize! = initialize!,
                update_state! = update_state!,
                final_stage! = final_stage!,
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
end

function finishing(w, json, BCAP_meta)
    sleep(2)
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

        json = JSON.parsefile(json_name)

        @js_ w begin
            document.getElementById("title").innerHTML = $(json["project-name"])
            document.getElementById("sub-title").innerHTML = $(json["target-algorithm-name"])
        end

        project_steps = [ loadInstances, staringBCAP, configuring, finishing ]

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


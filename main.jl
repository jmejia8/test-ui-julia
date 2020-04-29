using Blink
import JSON
import CSV
import Printf.@sprintf


include("utils.jl")
include("/home/jesus/develop/repos/bca-parameter/BCAP.jl")

include("components/createProject/createProject.jl")
include("components/projects/projects.jl")
include("components/runProject/runProject.jl")


"""
    bcapgui()
Function `bcapgui()` opens a graphical-user interface for creating and managing
BCAP projects.
"""
function bcapgui()
    main_projects()
end


bcapgui()

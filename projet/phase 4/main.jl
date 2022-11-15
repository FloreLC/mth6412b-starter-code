include("../phase 1/read_stsp.jl")
include("Comp_module.jl")
include("RSL_module.jl")
include("LK_module.jl")
include("MST_module.jl")
using DataFrames
using .Comp_module, .RSL_module, .LK_module, .MST_module

instance = ARGS[1]
instances_folder = joinpath("..", "..","instances")
@show instances_folder
file = joinpath(instances_folder, "stsp", "$(instance).tsp")
algorithms = [kruskal, prim]
step = [1]

grid = DataFrame(collect(Iterators.product(algorithms, step, [true, false])))


# create the object to save the results
results = DataFrame(Nodes = Int[], Algorithm = Function[], Tour = Bool[], Time = [], Adaptive = Bool[])


println("---- Solving instance $(instance) ----")
for j in range(1, size(grid)[1])
        
    graph = build_graph(file)
   
    # apply the algorithm to found the tour
    solution, cost, tour, time = lin_kernighan(graph, grid[j, 1], nodes(graph)[1], 1000, 60, grid[j, 2] * 1.0, grid[j, 3])

    # create mst with different techniques and add the times to the results object
    push!(results, [nb_nodes(graph), grid[j, 1], tour, time, grid[j, 3], ])
end


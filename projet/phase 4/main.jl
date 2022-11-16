include("../phase 1/read_stsp.jl")
include("RSL_module.jl")
include("LK_module.jl")
include("MST_module.jl")



using DataFrames


instance = ARGS[1]
instances_folder = joinpath("..", "..","instances")
@show instances_folder
file = joinpath(instances_folder, "stsp", "$(instance).tsp")
algorithms = [kruskal, prim]
step = [1.0, 2.0]


grid = DataFrame(collect(Iterators.product(algorithms, step, [true, false])))


# create the object to save the results
## FLORE we should get the value of each tour we findall
## Tour becomes an Union{NaN, Int}
results = DataFrame(Nodes = Int[], Algorithm = Function[], Costs = Float64[], Time = [], Adaptive = Bool[])


println("---- Solving instance $(instance) ----")
for j in range(1, size(grid)[1])
        
    graph = build_graph(file)
    # apply the algorithm to found the tour
    solution, cost, tour, time = lin_kernighan(graph, grid[j, 1], nodes(graph)[1], 1000, 60, [grid[j, 2], grid[j, 2] + 1], grid[j, 3])
   
    # create mst with different techniques and add the times to the results object
    push!(results, [nb_nodes(graph), grid[j, 1], cost, time, grid[j, 3], ])
end



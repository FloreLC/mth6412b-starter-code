# loading libraries
# using Pkg # how to do this optional?
# Pkg.add("DataFrames")
using DataFrames
# Pkg.add("StatsPlots")
using StatsPlots

"""
This script contains the test workflow for our algorithms.
"""

include("./Lin_Kernighan.jl")

"""
This part runs the algorithms over different instances. To do that, it saves the file's names and then apply the algorithms
sequentially. Besides, to save the results in terms of the running times and the number of nodes, a DataFrame is created to
plot the results afterwards.
"""
# this section will test the instances to check the running times with other instances
instances = [item for item in walkdir("../instances/stsp")][1][3]

# create the grid for experimentation
algorithms = ["Kruskal", "Prim"]
step = [10*i for i in 1:10]

grid = DataFrame(collect(Iterators.product(algorithms, step, [true, false])))


# create the object to save the results
results = DataFrame(Nodes = Int[], Algorithm = String[], Tour = Bool[], Time = [], Adaptive = Bool[])

# solve the instances under different configurations
for instance in instances
    for j in range(1, size(grid)[1])
        println("---- Solving instance $(instance) ----")
        graph = build_graph(instance)

        # apply the algorithm to found the tour
        Solution, Cost, Tour, Time = LinKernighan(graph, grid[j, 1], root = rand(1:nb_nodes(graph)), 1000, 60, grid[j, 2], grid[j, 3])

    # create mst with different techniques and add the times to the results object
    push!(results, [nb_nodes(graph), grid[j, 1], Tour, Time, grid[j, 3], ])
end

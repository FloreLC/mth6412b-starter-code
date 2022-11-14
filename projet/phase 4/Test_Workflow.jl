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
# instances = [item for item in walkdir("../../instances/stsp")][1][3]
# @show instances
instances = ["gr17.tsp"]

# create the grid for experimentation
algorithms = [prim]
# step = [10*i for i in 1:10]
step = [1]
grid = DataFrame(collect(Iterators.product(algorithms, step, [true, false])))


# create the object to save the results
results = DataFrame(Nodes = Int[], Algorithm = Function[], Tour = Bool[], Time = [], Adaptive = Bool[])

# solve the instances under different configurations
for instance in instances
    println("---- Solving instance $(instance) ----")
    for j in range(1, size(grid)[1])
        
        #graph = build_graph(instance)
       graph = test_graph()
        # apply the algorithm to found the tour
        Solution, Cost, Tour, Time = LinKernighan(graph, grid[j, 1], nodes(graph)[1], 1000, 60, grid[j, 2] * 1.0, grid[j, 3])

    # create mst with different techniques and add the times to the results object
    push!(results, [nb_nodes(graph), grid[j, 1], Tour, Time, grid[j, 3], ])
    end
end

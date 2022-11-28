# include required libraries
include("../phase 1/graph.jl")
include("../phase 4/RSL_module.jl")
include("../phase 4/LK_module.jl")


g = test_graph_complet()

tour, poids, elapsed_time = rsl(g, get_node(g, "1"), prim, true)
show(tour)
@show parcours_cycle(tour)

include("../phase 1/read_stsp.jl")
include("../phase 2/connex_componant.jl")
include("./prim.jl")
include("./new_connex.jl")



filename = ARGS[1]
graph = build_graph("../../instances/stsp/$(filename).tsp")

println("\n kruskal_heuristiques")
@time tree_kruskal_heur = kruskal_heuristiques(graph)
println("Poids: ", sum(weight.(edges(tree_kruskal_heur))))
println("\n Prim:")
@time tree_prim = prim(graph)
println("Poids: ", sum(weight.(edges(tree_prim))))


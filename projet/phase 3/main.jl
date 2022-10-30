
include("../phase 1/read_stsp.jl")
include("./prim.jl")
include("./heuristic1.jl")
include("heuristic2.jl")



filename = ARGS[1]
graph = build_graph("../../instances/stsp/$(filename).tsp")
println("\n kruskal")
@time tree_kruskal= kruskal(graph)
println("Poids: ", sum(weight.(edges(tree_kruskal))))
println("\n kruskal_heuristique 1")
@time tree_kruskal_heur = kruskal_heur1(graph)
println("Poids: ", sum(weight.(edges(tree_kruskal_heur))))
println("\n kruskal_heuristique 2")
@time tree_kruskal_heur2 = kruskal_heur2(graph)
println("Poids: ", sum(weight.(edges(tree_kruskal_heur2))))
println("\n Prim:")
@time tree_prim = prim(graph)
println("Poids: ", sum(weight.(edges(tree_prim))))


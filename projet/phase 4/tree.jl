
#include("./connex_componant.jl")
include("../phase 3/prim.jl")
include("../phase 1/read_stsp.jl")
function one_tree(g::Graph{T}, algorithm::Function, node_out::Node{T}) where T
    # the function should be something like 
    # tree(g::Graph{T}, algorithm::Function, node_out::Node{T}) where T

    # here, we should be able to retrieve the weights in the tree as well as the
    # degree of every node
    return algorithm(g, node_out)
end

# g = Graph{Char}()
#     for i in 1:9
#         n = Node(string('a' + i-1), 'a' + i-1)
#         add_node!(g, n)
#     end
#     add_edge!(g, Edge((get_node(g, "a"), get_node(g, "b")), 4))
#     add_edge!(g, Edge( (get_node(g, "a"), get_node(g, "h")), 8))
#     add_edge!(g, Edge((get_node(g, "b"), get_node(g, "h")), 11))
#     add_edge!(g, Edge((get_node(g, "b"), get_node(g, "c")), 8))
#     add_edge!(g, Edge((get_node(g, "h"), get_node(g, "i")), 7))
#     add_edge!(g, Edge((get_node(g, "g"), get_node(g, "h")), 1))
#     add_edge!(g, Edge((get_node(g, "i"), get_node(g, "g")), 6))
#     add_edge!(g, Edge((get_node(g, "i"), get_node(g, "c")), 2))
#     add_edge!(g, Edge((get_node(g, "g"), get_node(g, "f")), 2))
#     add_edge!(g, Edge((get_node(g, "c"), get_node(g, "f")), 4))
#     add_edge!(g, Edge((get_node(g, "c"), get_node(g, "d")), 7))
#     add_edge!(g, Edge((get_node(g, "d"), get_node(g, "f")), 14))
#     add_edge!(g, Edge((get_node(g, "d"), get_node(g, "e")), 9))
#     add_edge!(g, Edge((get_node(g, "f"), get_node(g, "e")), 10))

filename = ARGS[1]
g = build_graph("../../instances/stsp/$(filename).tsp")
tree_p = prim(g)
println("Prim weight:",sum(weight.(edges(tree_p))))
tree_k_baby, c_k_baby = kruskal(g)
println("Kruskal weight:",sum(weight.(edges(tree_p))))
tree_k, c_k = one_tree(g, kruskal_1_tree, nodes(g)[1])
@show degrees(c_k)
println("Kruskal 1 tree weight:",sum(weight.(edges(tree_k))))


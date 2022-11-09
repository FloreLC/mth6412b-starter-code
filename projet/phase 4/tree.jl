
#include("./connex_componant.jl")
include("../phase 3/prim.jl")
include("../phase 1/read_stsp.jl")
function one_tree(g::Graph{T}, algorithm::Function, root::Node{T}) where T
 
    to_remove = get_all_edges_with_node(g, root)

    nodes_copy = nodes(g)[findall(x->name(x)!=name(root),nodes(g))]
    #deleteat!(nodes(g), findall(x->name(x)==name(root),nodes(g)))
    # filter!(x -> !(x in to_remove), edges(g))
    edges_copy = filter(x -> !(x in to_remove), edges(g))

    tree , c = algorithm(Graph{T}("", nodes_copy, edges_copy))
    show.(edges(tree))
    leaves = filter(kv -> kv.second ==1, degrees(c))
    #get edges in to_remove between root & leaf
    edges_candidates = Vector{Edge{T}}()
    for l in  collect(keys(leaves))
        new = get_edge_in_list(to_remove, root, l)
        if !isnothing(new)
            push!(edges_candidates, new)
        end
    end
    edge_sorted = sort(edges_candidates, by=weight)
    #add the root and 2 cheapest arcs from the root to a leaf
    add_node!(tree, root)
    for i in 1:2
        e = pop!(edge_sorted)
        add_edge!(tree, e)
        increase_degree!(c, ends(e)[1]) 
        increase_degree!(c, ends(e)[2]) 
    end
    return tree, c
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

tree_prim, c_prim = prim(g)
println("Prim weight:",sum(weight.(edges(tree_prim))))
tree_k_baby, c_k_baby = kruskal(g)
println("Kruskal weight:",sum(weight.(edges(tree_k_baby))))
#tree_k, c_k = one_tree(g, kruskal, nodes(g)[1])
#println("Kruskal 1 tree weight:",sum(weight.(edges(tree_k))))
tree_p, c_p = one_tree(g, prim, nodes(g)[1])
println("Prim 1 tree weight:",sum(weight.(edges(tree_p))))
show.(edges(tree_p))

#include("./connex_componant.jl")
include("../phase 3/prim.jl")
include("../phase 1/read_stsp.jl")

"""
Take a graph, an algorithm and a root, and build a one-tree with this root. Returns the tree (a graph struct) and a component structure describing the tree.
"""
function one_tree(g::Graph{T}, algorithm::Function, root::Node{T}) where T
    # List the edges adjacents to the root
    to_remove = get_all_edges_with_node(g, root)

    # Creates a vector of all graph's node except the root 
    nodes_copy = nodes(g)[findall(x->name(x)!=name(root),nodes(g))]
   # Creates a vector of all graphs edges except the edges adjacent to the root 
    edges_copy = filter(x -> !(x in to_remove), edges(g))

    # Gets the MST tree and its corresponding connex component c for the subgraph g[V\{root}]
    tree , c = algorithm(Graph{T}("", nodes_copy, edges_copy))
    # Gets all the nodes with degree 1 in the MST tree

    #### the degree should not be filtered to 1 degree nodes but anyone since
    #### we need a cycle

    #leaves = filter(kv -> kv.second ==1, degrees(c))
    leaves = filter(kv -> kv.second >= 0, degrees(c))

    #edges_candidates = Vector{Edge{T}}()

    # Gather all the edges between root and the MST leaves
   

    # Order this edges by weight
    edge_sorted = sort(to_remove, by=weight)

    # Add the root and 2 cheapest arcs from the root to a leaf
    # Keep the component c updated
    # ATTENTION: from now on, because the tree is now a 1-tree, the component c does not contain the information for the edges touching root. 
    # We are keeping the degree dictionary updated
    add_node!(tree, root)
    for i in 1:2
        e = pop!(edge_sorted)

        add_edge!(tree, e)
        # If any of the 2 extremities is root, its degree wont be updated, because it wont be part of the dictionnary yet
        increase_degree!(c, ends(e)[1]) 
        increase_degree!(c, ends(e)[2]) 
    end
    degrees(c)[root] = 2

    return tree, c
end

# g = Graph{Char}()
#     for i in 1:9
#         n = Node(string('a' + i-1), 'a' + i-1)
#         add_node!(g, n)
#     end
#     add_edge!(g, Edge((get_node(g, "a"), get_node(g, "b")), 4.0))
#     add_edge!(g, Edge( (get_node(g, "a"), get_node(g, "h")), 8.0))
#     add_edge!(g, Edge((get_node(g, "b"), get_node(g, "h")), 11.0))
#     add_edge!(g, Edge((get_node(g, "b"), get_node(g, "c")), 8.0))
#     add_edge!(g, Edge((get_node(g, "h"), get_node(g, "i")), 7.0))
#     add_edge!(g, Edge((get_node(g, "g"), get_node(g, "h")), 1.0))
#     add_edge!(g, Edge((get_node(g, "i"), get_node(g, "g")), 6.0))
#     add_edge!(g, Edge((get_node(g, "i"), get_node(g, "c")), 2.0))
#     add_edge!(g, Edge((get_node(g, "g"), get_node(g, "f")), 2.0))
#     add_edge!(g, Edge((get_node(g, "c"), get_node(g, "f")), 4.0))
#     add_edge!(g, Edge((get_node(g, "c"), get_node(g, "d")), 7.0))
#     add_edge!(g, Edge((get_node(g, "d"), get_node(g, "f")), 14.0))
#     add_edge!(g, Edge((get_node(g, "d"), get_node(g, "e")), 9.0))
#     add_edge!(g, Edge((get_node(g, "f"), get_node(g, "e")), 10.0))

# filename = ARGS[1]
# g = build_graph("../../instances/stsp/$(filename).tsp")

# tree_prim, c_prim = prim(g)
# println("Prim weight:",sum(weight.(edges(tree_prim))))
# tree_k_baby, c_k_baby = kruskal(g)
# println("Kruskal weight:",sum(weight.(edges(tree_k_baby))))
# #tree_k, c_k = one_tree(g, kruskal, nodes(g)[1])
# #println("Kruskal 1 tree weight:",sum(weight.(edges(tree_k))))
# tree_p, c_p = one_tree(g, prim, nodes(g)[1])
# println("Prim 1 tree weight:",sum(weight.(edges(tree_p))))
# show.(edges(tree_p))

# for n in nodes(graph)
#     degree(c_p, n) # ordered
# end
# values(c_p)
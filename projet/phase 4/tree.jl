
include("./connex_componant.jl")
function tree(g::Graph{T}, algorithm::Function, max_degree::Int) where T
    return algorithm(g)#, max_degree)
end

g = Graph{Char}()
    for i in 1:9
        n = Node(string('a' + i-1), 'a' + i-1)
        add_node!(g, n)
    end
    add_edge!(g, Edge((get_node(g, "a"), get_node(g, "b")), 4))
    add_edge!(g, Edge( (get_node(g, "a"), get_node(g, "h")), 8))
    add_edge!(g, Edge((get_node(g, "b"), get_node(g, "h")), 11))
    add_edge!(g, Edge((get_node(g, "b"), get_node(g, "c")), 8))
    add_edge!(g, Edge((get_node(g, "h"), get_node(g, "i")), 7))
    add_edge!(g, Edge((get_node(g, "g"), get_node(g, "h")), 1))
    add_edge!(g, Edge((get_node(g, "i"), get_node(g, "g")), 6))
    add_edge!(g, Edge((get_node(g, "i"), get_node(g, "c")), 2))
    add_edge!(g, Edge((get_node(g, "g"), get_node(g, "f")), 2))
    add_edge!(g, Edge((get_node(g, "c"), get_node(g, "f")), 4))
    add_edge!(g, Edge((get_node(g, "c"), get_node(g, "d")), 7))
    add_edge!(g, Edge((get_node(g, "d"), get_node(g, "f")), 14))
    add_edge!(g, Edge((get_node(g, "d"), get_node(g, "e")), 9))
    add_edge!(g, Edge((get_node(g, "f"), get_node(g, "e")), 10))
show(tree(g, kruskal, 0))
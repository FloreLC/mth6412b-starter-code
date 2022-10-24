include("../phase 1/graph.jl")

using DataStructures
using Test

function prim(g::AbstractGraph)
    tree = Graph{typeof(data(nodes(g)[1]))}("Arbre couvrant de $(name(g)) (Prim)", copy(nodes(g)), Vector{AbstractEdge}())
    ## CREER UNE LISTE DES EDGES EN FONCTIONS DES NOEUDS ADJCENTS
    all_graph = Dict{AbstractNode, PriorityQueue{AbstractEdge, Int}}()
    for n in nodes(g)
        all_graph[n] = PriorityQueue{AbstractEdge, Int}()
        e_with_n = get_associated_edges(g, n)
        for e in e_with_n
            enqueue!(all_graph[n], e, weight(e))
        end
    end
    added_nodes = Vector{AbstractNode}()
    current_node = nodes(g)[rand(1:nb_nodes(g))]
    push!(added_nodes, current_node)
    while length(added_nodes) < nb_nodes(g)
        show(current_node)
        bound = Inf
        for n in added_nodes
            if length(all_graph[n])>0 && peek(all_graph[n])[2] < bound
                current_node = n
                bound = peek(all_graph[n])[2]
            end
        end
        e = dequeue!(all_graph[current_node])
        push!(edges(tree), e)
        
        name(ends(e)[1]) == name(current_node) ? current_node = ends(e)[2] : current_node = ends(e)[1]
        delete!(all_graph[current_node], e)
        push!(added_nodes, current_node)
    end
    return tree 
end

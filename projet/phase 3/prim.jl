include("../phase 1/graph.jl")
include("./new_connex.jl")

using DataStructures
using Test

"""
Prend en argument un graphe et un noeud
Retourne toutes les aretes du graphe incidente au noeud
"""
function get_all_edges_with_node(g::AbstractGraph, node::AbstractNode)
    edges = Vector{AbstractEdge}()
    for n in nodes(g)
        e = get_edge(g, node, n)
        if !isnothing(e)
            push!(edges,e)
        end
    end
   return edges
end

"""
Prend en parametre un vecteur des noeuds deja ajoutes a l'arbre de recouvrement et une arete
Retourne l'extremité de l'arete qui n'appartient pas encore a l'arbre
nothing sinon
"""
function node_to_add(nodes_added::Vector{Node{T}}, new_edge::Edge{T}) where T
    (n1, n2) = ends(new_edge)
    i1 = findfirst(x -> name(x) == name(n1), nodes_added)
    i2 = findfirst(x -> name(x) == name(n2), nodes_added)
    if (sum(isnothing.([i1, i2])) == 1)
        if isnothing(i1) 
            return n1
        else
            return n2
        end
    end
    return nothing
end

"""
Prend en parametre un grapheet renvoi un graphe qui est un de ses arbres de recouvrement minimum en utilisant l'algorithme de Prim.
"""
function prim(g::Graph{T}) where T
    
    edges_selected = Vector{Edge{T}}()

    #Toutes les aretes sont dans une queue de priorite. Le poids de l'arete sert d'indice de priorité. Plus l'arete est legere, plus elle est prioritaire
    edges_candidates = PriorityQueue{Edge{T}, Float64}(Base.Order.Reverse)
    for e in edges(g)
        enqueue!(edges_candidates, e, weight(e))
    end
    #on choisi au hasard une racine
    current_node = nodes(g)[rand(1:nb_nodes(g))]
    #On garde en memoire les noeuds couverts par l'arbre
    nodes_added =[current_node]

    #boolean qui indique quand il faut ajouter de nouvelles aretes aux aretes candidates
    node_updated = true

    #tant que tous les noeuds n<ont pas ete atteinds
    while length(nodes_added) < nb_nodes(g)

        if node_updated
            #On cherche toutes les aretes incidentes au noeud qu<on vient d'ajouter
            for e in get_all_edges_with_node(g, current_node)
                #On change la priorité de cette arete pour 1/le poids (elle devient donc PLUS prioritaire)
                #On assume ici que le poid des aretes est superieur ou egal a 1 (ce qui est possible wlog)
                edges_candidates[e] = 1/weight(e)
             end
        end
        node_updated = false
        #On recupere l'arete la moins chere ATTEIGNABLE
        new_edge = dequeue!(edges_candidates) 
       
        #On identifi quel noeud est ajouté avec l'ajout de cet arete
        new_node = node_to_add(nodes_added, new_edge)
  

        if !(isnothing(new_node))
            #On ajoute l'arete a l'arbre
            push!(edges_selected, new_edge)
            #On ajoute le nouveau noeud a notre liste
            push!(nodes_added, new_node)
            current_node = new_node
            node_updated = true
        end   
    end

    return Graph("Prim arbre couvrant min de $(name(g))", nodes(g), edges_selected)
end
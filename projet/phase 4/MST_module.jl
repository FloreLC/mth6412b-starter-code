module MST_module
include("./Comp_module.jl")
include("../phase 1/graph.jl")
using .Comp_module
export kruskal, prim 


"""
Prend en parametre un graphe et renvoi un arbre couvrant de poids minimum en utilisant l'algorithme de Kruskal
"""
function kruskal(g::Graph{T}) where T
    #Tri les aretes de g par poids croissant
    edge_sorted = sort(edges(g), by=weight)
    tree_comps = to_components(g)
    #garde en memoire les aretes selectionnees pour l'arbre
    edges_selected = Vector{Edge{T}}()
    for e in edge_sorted
        (new1, new2) = ends(e)

        comp1 = get_component_with_node(tree_comps, new1)
        comp2 = get_component_with_node(tree_comps, new2)

        if !isequal(comp1, comp2)
            push!(edges_selected, e)
          
            add_nodes_at!(comp1, comp2, e)
            ## add all elements of comp2 to comp1 except the node we attached already in the previous line

            filter!(x ->!isequal(x, comp2), tree_comps)
        end
    end

    return Graph{T}("Kruskal de $(name(g))", nodes(g), edges_selected), tree_comps[1]
end


"""
Prend en parametre un grapheet renvoi un graphe qui est un de ses arbres de recouvrement minimum en utilisant l'algorithme de Prim.
"""
function prim(g::Graph{T}) where T
    tree_comp = Component{T}()
   
    
    edges_selected = Vector{Edge{T}}()

    #Toutes les aretes sont dans une queue de priorite. Le poids de l'arete sert d'indice de priorité. Plus l'arete est legere, plus elle est prioritaire
    edges_sorted = MutableBinaryHeap{Edge{T}}(Base.By(weight))
    
    #on choisi au hasard une racine
    current_node = nodes(g)[1]#[rand(1:nb_nodes(g))]
    #On garde en memoire les noeuds couverts par l'arbre
    
    add_to_comp!(tree_comp, current_node, current_node, 0)
    for e in get_all_edges_with_node(g, current_node)
        push!(edges_sorted, e)
    end
    #boolean qui indique quand il faut mettre a jour les aretes candixsdates
    node_updated = false

    #tant que tous les noeuds n'ont pas ete atteinds
    while length(keys(links(tree_comp))) < nb_nodes(g) 
        if node_updated
            #On cherche toutes les aretes incidentes au noeud qu'on vient d'ajouter
            for e in get_all_edges_with_node(g, current_node)
                push!(edges_sorted, e)
            end
        end
       
        node_updated = false
        #On recupere l'arete la moins chere ATTEIGNABLE
        new_edge = pop!(edges_sorted)
       
        #On identifi quel noeud est ajouté avec l'ajout de cet arete
        child, parent = node_to_add(tree_comp, new_edge)
        if !(isnothing(child))
            
            #On ajoute l'arete a l'arbre
            add_to_comp!(tree_comp, child, parent, 1)
            push!(edges_selected, new_edge)
            #On ajoute le nouveau noeud a notre liste
            current_node = child
            node_updated = true
        end   
       
    end
    
    return Graph("Prim arbre couvrant min de $(name(g))", nodes(g), edges_selected), tree_comp
end

"""
Prend en argument un graphe et un noeud
Retourne toutes les aretes du graphe incidente au noeud
"""
function get_all_edges_with_node(g::Graph{T}, node::Node{T}) where T
    edges = Vector{Edge{T}}()
    for n in nodes(g)
        e = get_edge(g, node, n)
        if !isnothing(e)
            push!(edges,e)
        end
    end
   return edges
end

"""
Prend en parametre la composante connexe correspondant a l'arbre de recouvrement et une arete
Retourne un couple (enfant, parent) 
Avec enfant l'extremité de l'arete qui n'appartient pas encore a l'arbre, parent l'extremite deja dans la composante
(nothing, nothing) sinon
"""
function node_to_add(tree_comp::Component{T}, new_edge::Edge{T}) where T
    (n1, n2) = ends(new_edge)
    if haskey(links(tree_comp), n1)
        #n1 is parent
        if !haskey(links(tree_comp), n2)
            #n2 is child
            return n2, n1
        end
    elseif haskey(links(tree_comp), n2)
        return n1, n2
    end
    return nothing, nothing
end


end
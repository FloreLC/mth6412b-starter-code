import Base.show
using Test
include("../phase 1/graph.jl")

"""Type abstrait de composantes connexes"""
abstract type AbstractComp{T} end

"""Type composante connexe: un dictionnaire ou chaque clef est un noeud, et chaque valeur son parent"""
mutable struct Component{T} <: AbstractComp{T}
    # this adds the degree of the node that is going to be used as a constraint to construct the 1-tree
    # this might take the value 0, 1 or 2 in a 1-tree scheme
    nodes::Dict{Node{T}, Tuple{Node{T}, Int8}}
end

# it gets the node within the component
nodes(c::AbstractComp) = c.nodes

"""
Vide une composante connexe de ces noeuds
"""
function empty!(comp::AbstractComp{T}) where T
    comp.nodes = Dict{Node{T}, Tuple{Node{T}, Int8}}()
    comp
end


"""
Gives back the degree of a node n in componant c, 0n if the node is not part of the componant
"""
function degree(c::AbstractComp, n::Node{T}) where T
    if haskey(nodes(c), n)
        tmp, d = nodes(c)[n]
        return d
    end
    return 0
end


function set_degree!(c::AbstractComp{T}, n::Node{T}, new_degree::Int64) where T
    if haskey(nodes(c), n)
        nodes(c)[n] = (n, new_degree)
    end
    c
end
"""
Prend en argument un graphe et renvoi un vecteur de composantes connexes initiales (noeud n => noeud n)
"""
function to_components(g::Graph{T}) where T
    tmp = Vector{Component{T}}()
    for n in nodes(g)
        d= Dict{Node{T}, Tuple{Node{T}, Int8}}()
        d[n] = (n, 0)
        solo = Component{T}(d)
        push!(tmp, solo)
    end
    return tmp
end


#TODO delete! function instead of empty
# """
# Vide une composante connexe de ces noeuds
# """
# function empty!(comp::AbstractComp{T}) where T
#     comp.nodes = Dict{Node{T}, (Node{T}, Int8)}()
#     comp
# end

"""
Renvoi la composante connexe qui contient le noeud n
"""
function get_component_with_node(tree::Vector{Component{T}}, n::Node{T}) where T
    for c in tree
        if haskey(nodes(c), n)
            return c
        end
    end
    return nothing
end

""" 
Joins la composante connexe comp2 a la composante connexe comp1 en les liant au niveau de l'arete e
"""
function add_nodes_at!(comp1::AbstractComp{T}, comp2::AbstractComp{T}, e::AbstractEdge{T}) where T
    new1, new2 = ends(e)

    mask = new1
    if haskey(nodes(comp1),new1)
        # add starting node to the component
        nodes(comp1)[new1] = (new2, degree(comp1, new1) + 1)
        mask = new2
        #################################################
        # increases the degree of the node recently added
        #################################################
        #set_degree!(comp1, new1, degree(comp1, new1) + 1)
    elseif haskey(nodes(comp1),new2)
        # add destination node to the component
        nodes(comp1)[new2] = (new1, degree(comp2, new2) + 1)
        #################################################
        # increases the degree of the node recently added
        #################################################
        # set_degree!(comp1, new2, degree(comp2, new2) + 1)
    end
    # is this loop necessary?
    for (k,v) in nodes(comp2)
       
        nodes(comp1)[k] = v
        
    end
    set_degree!(comp1, mask, degree(comp2, mask)+1) 
    comp1
end

"""
Renvoi true si les deux composantes connexes sont les memes
"""
function same_component(comp1::AbstractComp, comp2::AbstractComp)
    if length(nodes(comp1)) != length(nodes(comp2))
        return false
    else
        for n in keys(nodes(comp1))
            if !haskey(nodes(comp2), n)
                return false
            end
        end
    end
    return true
end

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

        if !same_component(comp1, comp2) && degree(comp1, new1) < 2 && degree(comp2, new2) < 2
            push!(edges_selected, e)
            add_nodes_at!(comp1, comp2, e)
            empty!(comp2)
        end
    end
    c = findfirst(x -> length(nodes(x))> 0, tree_comps)
    return Graph{T}("Kruskal de $(name(g))", nodes(g), edges_selected), tree_comps[c]
end

"""
Prend en parametre un graphe et renvoi un arbre couvrant de poids minimum en utilisant l'algorithme de Kruskal
"""
function kruskal_1_tree(g::Graph{T}, root::Node{T}) where T

    to_remove =  get_associated_edges(g, root)
    #### Remove the root
    deleteat!(nodes(g), findall(x->name(x)==name(root),nodes(g)))
    
    
    filter!(x -> isnothing(findfirst(y -> isequal(x,y), to_remove)), edges(g))
    #edges = delete!.(edges(g), to_remove)
    tree , c = kruskal(g)
    #list nodes with degre 1 (leaves)

    leaves = findall(x -> x[2] == 1, collect(values(nodes(c))))
    #get edges in to_remove between root & leaf
    edges_candidates = Vector{Edge{T}}()

    for l in  collect(keys(nodes(c)))[leaves]


        new = get_edge_in_list(to_remove, root, l)

        if !isnothing(new)
            push!(edges_candidates, new)
        end
    end
    edge_sorted = sort(edges_candidates, by=weight)

    #add the 2 cheapest arcs
    add_node!(tree, root)
    add_edge!(tree, pop!(edge_sorted))
    add_edge!(tree, pop!(edge_sorted))

    return tree
end
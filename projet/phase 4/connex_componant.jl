import Base.isequal
using Test
include("../phase 1/graph.jl")

"""Type abstrait de composantes connexes"""
abstract type AbstractComp{T} end

"""Type composante connexe: un dictionnaire ou chaque clef est un noeud, et chaque valeur son parent"""
mutable struct Component{T} <: AbstractComp{T}
    # this adds the degree of the node that is going to be used as a constraint to construct the 1-tree
    # this might take the value 0, 1 or 2 in a 1-tree scheme
    links::Dict{Node{T}, Node{T}}
    degrees::Dict{Node{T}, Int}
end

# it gets the node within the component
links(c::AbstractComp) = c.links
degrees(c::AbstractComp) = c.degrees

"""
Vide une composante connexe de ces noeuds
"""
function empty!(comp::AbstractComp{T}) where T
    delete!(links(comp), keys(links(comp)))
    delete!(degrees(comp), keys(degrees(comp)))
    comp
end


"""
Gives back the degree of a node n in componant c
"""
function degree(c::AbstractComp, n::Node{T}) where T
    return degrees(c)[n]
end

"""
Met a jour le degre d'un noeud dans un arbre en construction. Si le noeud n'appartient pas a la composante, ajoute le noeud
"""
function set_degree!(c::AbstractComp{T}, n::Node{T}, new_degree::Int64) where T
    degrees(c)[n] = new_degree
    c
end

"""
Incremente de 1 le degre d'un noeud dans un arbre en construction. Si le noeud n'appartient pas a la composante, ajoute le noeud avec un degre 1
"""
function increase_degree!(c::AbstractComp{T}, n::Node{T}) where T
    if haskey(degrees(c), n)
        degrees(c)[n] = degrees(c)[n] +1
    end
    c
end

"""
Compare deux composantes connexes
"""
function isequal(c1::AbstractComp, c2::AbstractComp)
    return isequal(links(c1), links(c2)) && isequal(degrees(c1), degrees(c2))
end

"""
Prend en argument un graphe et renvoi un vecteur de composantes connexes initiales (noeud n => noeud n)
"""
function to_components(g::Graph{T}) where T
    tmp = Vector{Component{T}}()
    for n in nodes(g)
        l = Dict{Node{T}, Node{T}}()
        d = Dict{Node{T}, Int}()
        l[n] = n
        d[n] = 0
        solo = Component{T}(l, d)
        push!(tmp, solo)
    end
    return tmp
end


"""
Renvoi la composante connexe qui contient le noeud n
"""
function get_component_with_node(tree::Vector{Component{T}}, n::Node{T}) where T
    for c in tree
        if haskey(links(c), n)
            return c
        end
    end
    return nothing
end

function remove_from_comp!(c::AbstractComp{T}, n::Node{T}) where T
    delete!(links(c), n)
    delete!(degrees(c), n)
    c
end

function merge_comp!(comp1::AbstractComp, comp2::AbstractComp)
    comp1.links = Dict(links(comp1)..., links(comp2)...)
    comp1.degrees = Dict(degrees(comp1)..., degrees(comp2)...)
    comp1
end

""" 
Joins la composante connexe comp2 a la composante connexe comp1 en les liant au niveau de l'arete e, et met les degrees a jour
"""
function add_nodes_at!(comp1::AbstractComp{T}, comp2::AbstractComp{T}, e::AbstractEdge{T}) where T
    new1, new2 = ends(e)
    if haskey(links(comp1),new1)
        # add starting node to the component
        links(comp1)[new2] = new1
        ##################################################################
        # increases the degree for the nodes adjacents to the new edge e #
        ##################################################################   
        increase_degree!(comp1, new1)
        set_degree!(comp1, new2, degree(comp2, new2)+1) 
        remove_from_comp!(comp2, new2)
    elseif haskey(links(comp1),new2)
        # add destination node to the component
        links(comp1)[new1] = new2 
        ##################################################################
        # increases the degree for the nodes adjacents to the new edge e #
        ##################################################################
        set_degree!(comp1, new1, degree(comp2, new1)+1)
        increase_degree!(comp1, new2) 
        remove_from_comp!(comp2, new1)
    end
    merge_comp!(comp1, comp2)
    comp1
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
Prend en parametre un graphe et renvoi un arbre couvrant de poids minimum en utilisant l'algorithme de Kruskal
"""
function kruskal_1_tree(g::Graph{T}, root::Node{T}) where T

    to_remove =  get_associated_edges(g, root)
    #### Remove the root
    deleteat!(nodes(g), findall(x->name(x)==name(root),nodes(g)))
    filter!(x -> isnothing(findfirst(y -> isequal(x,y), to_remove)), edges(g))

    tree , c = kruskal(g)
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
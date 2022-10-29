import Base.show
using Test
include("../phase 1/graph.jl")

"""Type abstrait de composantes connexes"""
abstract type AbstractComp{T} end

"""Type représentant une composante connexe comme un noeud, une racine (heuristique 2), un rang (heuristique 1).
"""
mutable struct Component_rg{T} <: AbstractComp{T}
  nodes::Vector{Node{T}}
  root::Node{T}
  rang::Int
end

root(c::AbstractComp) = c.root 

nodes(c::AbstractComp) = c.nodes 

rang(c::Component_rg{T}) where T = c.rang

function set_rang!(c::Component_rg{T}, rg::Int) where T
    c.rang = rg
    c
end

function set_root!(c::Component_rg{T}, n::Node{T}) where T
    c.root = n
    c
end

"""
Prend en parametre un noeud et un vecteur de composantes connexes
Retourne la composante connexe a laquelle ce noeud appartient, 0 sinon
"""
function get_component(n::Node{T}, tree_comp::Vector{Component_rg{T}}) where T
    c = 1
   
    for comp in tree_comp
        i = findfirst(x->name(x) == name(n), nodes(comp))
        if !isnothing(i)
            break
        end
        c+=1
    end

    return tree_comp[c]
end

"""
Prend en parametre un graphe
Retourne un vecteur de composantes connexes telles que:
- Chaque composante possede un seul noeud
- Ce noeud est sa propre racine
- Le rang est 0
"""
function to_components(g::Graph{T}) where T
    tmp = Vector{Component_rg{T}}()
    for n in nodes(g)
        jpp = Vector{Node{T}}()
        push!(jpp, n)
        solo = Component_rg{T}(jpp, n, 0)
        push!(tmp, solo)
    end
    return tmp
end

function set_nodes!(comp::Component_rg{T}, new::Vector{Node{T}}) where T
    comp.nodes = new
    comp
end

"""
Vide une composante connexe de ces noeuds
"""
function empty!(comp::Component_rg{T}) where T
    comp.nodes = Vector{Node{T}}()
    comp
end

"""
Prend en parametre un graphe et renvoi un graphe qui en est un arbre couvrant a cout minimum en utilisant l'algorithme de Kruskal muni des 2 heuristiques
"""
function kruskal_heuristiques(g::Graph{T}) where T
	#Tri les aretes de g par poids croissant
    edge_sorted = sort(edges(g), by=weight)
	tree_comps = to_components(g)
    #garde en memoire les aretes selectionnees pour l'arbre
    edges_selected = Vector{Edge{T}}()
	for e in edge_sorted
        (new1, new2) = (get_node(g, name(ends(e)[1])), get_node(g, name(ends(e)[2])))
        comp1 = get_component(new1, tree_comps)
        comp2 = get_component(new2, tree_comps)
        if name(root(comp1)) != name(root(comp2))
            push!(edges_selected, e)
            if rang(comp1) > rang(comp2)
                #### ajoute new 2 a la composante de new 1
                set_nodes!(comp1, cat(nodes(comp1), nodes(comp2), dims = 1))
                ### on enleve new 2 de sa composante
                empty!(comp2)
            else
                set_nodes!(comp2, cat(nodes(comp1), nodes(comp2),  dims = 1) )
                empty!(comp1)
                if rang(comp1) == rang(comp2)
                    set_rang!(comp2, rang(comp2) +1)
                end
            end
        end
    end

    return Graph{T}("Heuristique 1 kruskal de $(name(g))", nodes(g), edges_selected)
end
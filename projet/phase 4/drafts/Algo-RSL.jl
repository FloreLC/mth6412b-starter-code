import Base.isequal
using Test
include("../phase 1/graph.jl")
include("./connex_componant.jl")
include("../phase 1/read_stsp.jl")

  mutable struct Tree{T} <: AbstractNode{T}
    name::String
    data::T
    children::Vector{Tree{T}}
    parent::Union{Tree{T}, Nothing}
  end

  function Tree(data::T, name::String="", children ::Vector{Tree{T}}=Vector{Tree{T}}(),
    parent::Union{Tree{T}, Nothing}=nothing ) where T
    Tree(name, data, children, parent)
   end

    children(bt::Tree) = bt.children
    parent(bt::Tree)=bt.parent
function show(tree::Tree{T}) where T
    println("$(name(tree)) a les enfants:")
    for n in children(tree)
        show(children(n))
    end
end
    function parcours_preordre!(tree::Union{Tree{T},Nothing}, list::Vector{Tree{T}}) where T
        isnothing(tree) && return 
        push!(list, tree)
        for t in children(tree)
            parcours_preordre!(t, list)
        end
        list
    end
 """
 Renvoi true si l'inégalité triangulaire est vérifiée dans un graphe g , false sinon
 """
 function condition(g::Graph{T}) where T
    resultats = Vector{Bool}()
    for e in edges(g)
        (new1, new2) = ends(e)
      
        for new3 in nodes(g)
            if !isnothing(get_edge(g, new1, new3)) && !isnothing(get_edge(g, new2, new3))
                if  weight(e) <= weight(get_edge(g, new1, new3))+weight(get_edge(g, new2, new3))
                    push!(resultats, true) 
                else 
                    push!(resultats, false)
                end
            end
        end
    end
    return all(resultats)
end

println("---------------------------------------------------")
println("--- Algorithme de Rosenkrantz, Stearns et Lewis ---")
println("---------------------------------------------------")

"""
Prend en parametre un graphe et renvoi une tournée de poids minimum en utilisant l'algorithme de RSL
"""
function create_child!(g::Graph{T}, parent::Tree{T}, deja_la::Vector{Node{T}}) where T
    root = Node{T}(name(parent), data(parent))
    for n in nodes(g)
        if isnothing( findfirst(x -> name(x)== name(n),deja_la)) && !isnothing(get_edge(g, root, n))
            new_item = Tree{T}(name(n), data(n), Vector{Tree{T}}(), parent)
            push!(deja_la, n)
            push!(children(parent), new_item)
        end
    end

    for c in children(parent)
        create_child!(g, c, deja_la)
    end

    parent
end

function AlgoRSL(g::Graph{T}, root::Node{T}) where T
    println("Condition: $(condition(g))")
  if condition(g)==true
       
        #calculer l'arbre de recouvrement minimal avec cette root
        arbre, composante = kruskal(g)
        show(arbre)
        #ordonner les sommets du graphe suivant un parcours en préordre de l'arbre
         
         ## Creer un objet de la structure tree
        tree_structure = Tree{T}(name(root), data(root),  Vector{Tree{T}}(), nothing)
        create_child!(arbre, tree_structure, [root])
    
        
  end
    list = Vector{Tree{T}}()
    parcours_preordre!(tree_structure, list)
    @show name.(list)

    tour_edges = Vector{Edge{T}}()
    for i in 1:(length(list) - 1)
        e = get_edge(g, Node{T}(name(list[i]), data(list[i])), Node{T}(name(list[i+1]), data(list[i+1])))
        if !(isnothing(e))
            push!(tour_edges, e)
        end
    end
    e = get_edge(g, Node{T}(name(list[1]), data(list[1])), Node{T}(name(list[end]), data(list[end])))
    if !(isnothing(e))
        push!(tour_edges, e)
    end
    poids = sum(weight.(tour_edges))
    println("Poids de la tournee: $(poids)")

    return Graph{T}("Tour de $(name(g))", nodes(g), tour_edges)
end

# g = Graph{Char}()
# for i in 1:6
#     n = Node(string('a' + i-1), 'a' + i-1)
#     add_node!(g, n)
# end
# add_edge!(g, Edge((get_node(g, "a"), get_node(g, "b")), 1))
# add_edge!(g, Edge((get_node(g, "b"), get_node(g, "c")), 1))
# add_edge!(g, Edge((get_node(g, "c"), get_node(g, "d")), 1))
# add_edge!(g, Edge((get_node(g, "d"), get_node(g, "e")), 1))
# add_edge!(g, Edge((get_node(g, "a"), get_node(g, "e")), 1))
# add_edge!(g, Edge((get_node(g, "a"), get_node(g, "f")), 1))
g = build_graph("C:\\Users\\Admin\\Desktop\\Projet\\mth6412b-starter-code-phase4\\instances\\stsp\\bayg29.tsp")

show(AlgoRSL(g, nodes(g)[1]))

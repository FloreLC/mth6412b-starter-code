import Base.show
using Test
include("./graph.jl")

"""Type abstrait de composantes connexes"""
abstract type AbstractConComp{T} end

"""Type représentant une composante connexe comme un noeud et sa racine.
"""
mutable struct Componant{T} <: AbstractConComp{T}
  node::Node{T}
  root::Node{T}
end

"""
Renvoi la liste des noeuds de la composante connexe.
"""
node(comp::AbstractConComp) = comp.node
root(comp::AbstractConComp) = comp.root

"
Renvoi la racine de l'arbre auquel appartient new 
"
function trace_back(comp::Vector{Componant{T}}, new::Componant{T}) where T
    current = root(new)
    while is_different(root(current), node(current))
        current = root(current)
    end
    return current
end

"""
Renvoi le vecteur de composantes connexes decrivant un arbre couvrant auquel on a ajouté la composante connexe new a l'element i
"""
function add!(comp::Vector{Componant{T}}, i::Int, new::Componant{T}) where T
    push!(comp, new)
    new.root= node(comp[i])
    comp
end

"Renvoi le vecteur des composantes connexes associees a un graphe. Il y en a autant que de nodes dans le graphe"
function to_components(graph::Graph{T}) where T
    comp = Vector{Componant{T}}()
    for n in nodes(graph)
        push!(comp, Componant(n,n))
    end
    return comp
end

@testset "struct Componant tests" begin
	@testset "tests general cases" begin
        g = Graph{Int}()
        for i in 1:3
            add_node!(g, Node("$i", i))  
        end
        add_edge!(g, Edge((get_node(g, "1"), get_node(g, "2")), 1))
        add_edge!(g, Edge((get_node(g, "2"), get_node(g, "3")), 1))
        add_edge!(g, Edge((get_node(g, "1"), get_node(g, "3")), 10))
		
		comp = to_components(g)
        @test length(comp) == nb_nodes(g)
        
	end
	@testset "tests for special cases" begin ## loop or empty vecteur
		#@test (@test_logs (:warn,"empty graph, returns empty Vector") length(to_components(Graph{Int}()))  0)
    end

end
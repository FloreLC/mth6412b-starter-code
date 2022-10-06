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
root(comp::Componant{T}) where T= comp.root

function set_root!(comp::Componant{T}, n::Node{T}) where T
    comp.root = n
    comp
end

"
Renvoi la racine de l'arbre auquel appartient new 
"
function trace_back(comp::Vector{Componant{T}}, new::Componant{T}) where T
    current = new
    while name(root(current)) != name(node(current))
        current = get_component(comp, name(root(current)))
    end
    return current
end

"""
Renvoi le vecteur de composantes connexes decrivant un arbre couvrant auquel on a ajouté la composante connexe new avec pour racine la composante connexe root
"""
function add!(comp::Vector{Componant{T}}, root::Componant{T}, new::Componant{T}) where T
    push!(comp, new)
    new.root= node(root)
    comp
end
"""
Renvoi le vecteur de composantes connexes auquel on a ajouté la composante connexe new 
"""
function add!(comp::Vector{Componant{T}}, new::Componant{T}) where T
    push!(comp, new)
    comp
end

"Renvoi le vecteur des composantes connexes associees a un graphe. Il y en a autant que de nodes dans le graphe"
function to_components(graph::Graph{T}) where T
    comp = Vector{Componant{T}}()
    for n in nodes(graph)
        push!(comp, to_component(n))
    end
    return comp
end

function to_component(n::Node{T}) where T
    return Componant(n,n)
end

function get_component(comp::Vector{Componant{T}}, s::String) where T
    i = findfirst(x -> ( name(node(x)) == s), comp)  
    if isnothing(i)
        return i 
    end
    return comp[i]
end

@testset "struct Componant tests" begin
    node4 = Node("4", 4)
    com4 = to_component(node4)
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
        @test name(node(get_component(comp, "1"))) == name(get_node(g, "1"))
        @test data(node(get_component(comp, "1"))) == data(get_node(g, "1"))
       
        set_root!(get_component(comp, "3"), node(get_component(comp, "2"))) 
        set_root!(get_component(comp, "2"), node(get_component(comp, "1"))) 
        trace_back(comp, get_component(comp, "3"))
        @test name(node(trace_back(comp, get_component(comp, "3")))) == name(node(get_component(comp, "1")))
        
        add!(comp, get_component(comp, "3"), com4)
        @test length(comp) == nb_nodes(g) + 1
        @test name(node(trace_back(comp, get_component(comp, "4")))) == name(node(get_component(comp, "1")))
        
	end
	@testset "tests for special cases" begin ## loop or empty vecteur
		#@test (@test_logs (:warn,"empty graph, returns empty Vector") length(to_components(Graph{Int}()))  0)
        g = Graph{Int}()
        comp_g = to_components(g)
        @test length(nodes(g)) ==  0
        @test length(comp_g) ==  0
        @test isnothing(get_component(comp_g, "1"))
        add!(comp_g, com4)
        @test length(comp_g) ==  1
    end

end
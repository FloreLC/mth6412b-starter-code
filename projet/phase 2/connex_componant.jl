import Base.show
using Test
include("../phase 1/graph.jl")

"""Type abstrait de composantes connexes"""
abstract type AbstractConComp{T} end

"""Type représentant une composante connexe comme un noeud et sa racine.
"""
mutable struct Component{T} <: AbstractConComp{T}
  node::Node{T}
  root::Node{T}
end

"""
Renvoi le noeud correspondant a la composante connexe.
"""
node(comp::AbstractConComp) = comp.node

"""
Renvoi le noeud correspondant a la racine du noeud de la composante connexe.
"""
root(comp::Component{T}) where T= comp.root

"""
Prend en parametre une composante connexe et un noeud n. Renvoi la composante connexe en ayant changé sa racine pour le noeud n.
"""
function set_root!(comp::Component{T}, n::Node{T}) where T
    comp.root = n
    comp
end

"""
Renvoi la composante correspondant a la racine de l'arbre auquel appartient new 
"""
function trace_back(comp::Vector{Component{T}}, new::Component{T}) where T
    current = new
    while name(root(current)) != name(node(current))
        current = get_component(comp, name(root(current)))
    end
    return current
end

"""
Prend un vecteur de composantes connexes et renvoi le nom de la racine de la composante contenant new 
"""
function name_og_root(comp::Vector{Component{T}}, new::Component{T}) where T
    n = name(node(trace_back(comp, new))) 
    return n
end

"""
Renvoi le vecteur de composantes connexes decrivant un arbre couvrant auquel on a ajouté la composante connexe new avec pour racine la composante connexe root
"""
function add!(comp::Vector{Component{T}}, root::Component{T}, new::Component{T}) where T
    push!(comp, new)
    new.root= node(root)
    comp
end

"""
Renvoi le vecteur de composantes connexes auquel on a ajouté la composante connexe new 
"""
function add!(comp::Vector{Component{T}}, new::Component{T}) where T
    push!(comp, new)
    comp
end

"""Renvoi le vecteur des composantes connexes associees a un graphe. Il y en a autant que de nodes dans le graphe"""
function to_components(graph::Graph{T}) where T
    comp = Vector{Component{T}}()
    for n in nodes(graph)
        push!(comp, to_component(n))
    end
    return comp
end

"""
Renvoi une composante connexe singloton correspondante au noeud n
"""
function to_component(n::Node{T}) where T
    return Component(n,n)
end

""" 
Renvoi l'element du vecteur comp tel que s est le nom du noeud de la composante.
"""
function get_component(comp::Vector{Component{T}}, s::String) where T
    i = findfirst(x -> ( name(node(x)) == s), comp)  
    if isnothing(i)
        return i 
    end
    return comp[i]
end

""" 
Renvoi l'index de l'element du vecteur comp tel que s est le nom du noeud de la composante.
"""
function get_component_index(comp::Vector{Component{T}}, s::String) where T
    return findfirst(x -> ( name(node(x)) == s), comp)  
end

"""
Prend en parametre un graphe g et son vecteur de composantes connexes associé.
Construit le graphe correspondant au sous graphe de g décrit par le vecteur de composantes connexes

"""
function to_graph(comp::Vector{Component{T}}, g::Graph{T}) where T

    tree = Graph{T}("covering tree (kruskal) of $(name(g))", copy.(nodes(g)), Vector{Edge{T}}())
    for i in 1:nb_nodes(tree)
        current=comp[i]
        if name(root(current)) != name(node(current))
            e = get_edge(g, root(current), node(current))
            push!(edges(tree), Edge{T}((root(current), node(current)), weight(e)))
        end
    end
    return tree
end

"""
Renvoi true si c est sa propre racine, false sinon
"""
function is_lonely(c::AbstractConComp)
    return name(node(c)) == name(root(c))
end

"""
Prend en parametre un graphe
    - Construit un vecteur de composantes connexes telles que chaque element est un noeud du graphe avec elle meme pour racine
    - Applique l'algorithme de kruskal au graphe et en garde la progression dans le vecteur de composantes connexes
    - retourne un objet graphe correspondant a l'arbre couvrant minimal obtenu.
"""
function kruskal(g::Graph{T}) where T
	
	#Construit un vecteur de composantes connexes telles que chaque element est un noeud du graphe avec elle meme pour racine
    comp = to_components(g)

	#Tri les aretes de g par poids croissant
    edge_sorted = sort(edges(g), by=weight)
	
	for e in edge_sorted
		#Recuperes la composante de chaque extremite de l'arete e
    	new1 = get_component(comp, name(ends(e)[1]))
    	new2 = get_component(comp, name(ends(e)[2]))

    	#Si new1 et new2 ne font pas parti de la meme composante connexe
    	if name_og_root(comp, new1) != name_og_root(comp, new2)
			
        	#Si new1 est sa propre racine
        	if is_lonely(new1)
            	set_root!(new1, node(new2))
				
        	#Sinon Si new2 est sa propre racine
        	elseif is_lonely(new2)
            	set_root!(new2, node(new1))
        	end
			
    	end
	end
	#Renvoi le graphe construit a partir du vecteur de composantes connexes
	return to_graph(comp, g)
end

@testset "Tests Component structure" begin
    node4 = Node("4", 4)
    com4 = to_component(node4)
	@testset "General cases" begin
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

        @test nb_nodes(to_graph(comp, g)) == 3
        
        add!(comp, get_component(comp, "3"), com4)
        @test length(comp) == nb_nodes(g) + 1
        @test name(node(trace_back(comp, get_component(comp, "4")))) == name(node(get_component(comp, "1")))
        @test nb_edges(to_graph(comp, g)) == 2
        
	end
	@testset "Special cases" begin ## loop or empty vecteur
		#@test (@test_logs (:warn,"empty graph, returns empty Vector") length(to_components(Graph{Int}()))  0)
        g = Graph{Int}()
        comp_g = to_components(g)
        @test length(nodes(g)) ==  0
        @test length(comp_g) ==  0
        @test isnothing(get_component(comp_g, "1"))
        tree = kruskal(g)
        @test sum(weight.(edges(tree))) == 0 
        add!(comp_g, com4)
        @test length(comp_g) ==  1
    end

    @testset "Kruskal" begin
        @testset "Exemple du cours" begin
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
            tree = kruskal(g)
            @test sum(weight.(edges(tree))) == 37
            @test length(nodes(tree)) == length(nodes(g))
            @test length(edges(tree)) == 8
        end
        
    end

end

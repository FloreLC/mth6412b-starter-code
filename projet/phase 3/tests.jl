include("../phase 2/connex_componant.jl")
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

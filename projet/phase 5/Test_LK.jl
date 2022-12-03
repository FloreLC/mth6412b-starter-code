include("../phase 1/graph.jl")
# include("../phase 4/LK_module.jl")
include("../phase 4/LK_module_2.jl")

g = Graph{Int}("Test", Vector{Node}(), Vector{Edge}())
for i in 1:9
    n = Node(string('a' + i-1), i)
    add_node!(g, n)
end

add_edge!(g, Edge((get_node(g, "a"), get_node(g, "b")), 4.0))
add_edge!(g, Edge((get_node(g, "a"), get_node(g, "h")), 8.0))
add_edge!(g, Edge((get_node(g, "b"), get_node(g, "h")), 11.0))
add_edge!(g, Edge((get_node(g, "b"), get_node(g, "c")), 8.0))
add_edge!(g, Edge((get_node(g, "h"), get_node(g, "i")), 7.0))
add_edge!(g, Edge((get_node(g, "g"), get_node(g, "h")), 1.0))
add_edge!(g, Edge((get_node(g, "i"), get_node(g, "g")), 6.0))
add_edge!(g, Edge((get_node(g, "i"), get_node(g, "c")), 2.0))
add_edge!(g, Edge((get_node(g, "g"), get_node(g, "f")), 2.0))
add_edge!(g, Edge((get_node(g, "c"), get_node(g, "f")), 4.0))
add_edge!(g, Edge((get_node(g, "c"), get_node(g, "d")), 7.0))
add_edge!(g, Edge((get_node(g, "d"), get_node(g, "f")), 14.0))
add_edge!(g, Edge((get_node(g, "d"), get_node(g, "e")), 9.0))
add_edge!(g, Edge((get_node(g, "f"), get_node(g, "e")), 10.0))

const STEP = [1.0, 1.0]
const ADAPT = true
const RAND_ROOT = false
const TL = 60
const ALGO = kruskal

# tour, cost, is_tour, elapsed_time, tour_comp, graph_modified_weight = lin_kernighan(g, ALGO, get_node(g,"a"), 1000000000, TL, STEP, ADAPT, RAND_ROOT)
tour, cost, is_tour, elapsed_time, tour_comp, graph_modified_weight = lin_kernighan(g, ALGO, get_node(g,"a"), 25, TL, STEP)

edges(tour)

@show tour

using Test
using BenchmarkTools

if is_tour
    @testset "Exemple du cours" begin
        @test sum(weight.(edges(tour))) == 61
        @test length(nodes(tour)) == length(nodes(g))
        @test length(edges(tour)) == length(nodes(g))
    end
end

edges(tour)